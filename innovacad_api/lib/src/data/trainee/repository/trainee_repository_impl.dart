import 'package:dio/dio.dart';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/trainee/repository/i_trainee_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart' as v;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

@v.Repository()
class TraineeRepositoryImpl implements ITraineeRepository {
  final RemoteUserService _remoteUserService;
  final Dio dio;
  final String table = "trainees";
  final String userTable = "user";
  final String relationFields =
      "t.trainee_id, t.user_id, t.birthday_date, u.emailVerified, u.twoFactorEnabled, u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt";

  TraineeRepositoryImpl(this._remoteUserService, this.dio);

  @override
  Future<Result<List<OutputTraineeDao>>> getAll() async {
    final List<OutputTraineeDao> daos = [];
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final query =
            "SELECT $relationFields FROM `trainees` t JOIN `user` u ON t.user_id = u.id";
        final results = await db.query(query);

        for (var row in results.rowsAssoc) {
          daos.add(OutputTraineeDao.fromJson(row.assoc()));
        }

        return Result.success(daos);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"stack": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputTraineeDao>> getById(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.query(
          "SELECT $relationFields "
          "FROM `trainees` t JOIN `user` u ON t.user_id = u.id WHERE t.trainee_id = ? LIMIT 1",
          whereValues: [id],
          isStmt: true,
        );

        if (results.rows.length == 0) {
          return Result.failure(
            AppError(AppErrorType.notFound, "Trainee not found"),
          );
        }

        return Result.success(OutputTraineeDao.fromJson(results.rows[0]));
      });
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTraineeDao>> create(CreateTraineeDto dto) async {
    MysqlUtils? db;
    String? createdUserId;

    try {
      db = await MysqlConfiguration.getConnection();

      final checkExists = await db.query(
        "SELECT id FROM user WHERE email = ? OR username = ? LIMIT 1",
        whereValues: [dto.email, dto.username],
        isStmt: true,
      );

      if (checkExists.rows.isNotEmpty) {
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "A trainee with the username or email provided already exists.",
          ),
        );
      }

      final responseUser = await _remoteUserService.signUpUser(
        dto.email,
        dto.name,
        dto.password,
      );

      if (responseUser.isFailure) {
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Failed to signup the trainee user.",
            details: {"error": responseUser.error},
          ),
        );
      }

      final role = "trainee";
      final userData = responseUser.data as Map<String, dynamic>;
      userData["username"] = dto.username;
      userData["role"] = role;
      createdUserId = userData["id"];

      await db.startTrans();

      final updateCount = await db.update(
        table: "user",
        updateData: {"username": dto.username, "role": role},
        where: {"id": createdUserId},
      );

      if (updateCount < BigInt.from(0)) {
        throw "Something went wrong while updating the role or username.";
      }

      final traineeId = Uuid().v4();

      await db.insert(
        table: table,
        insertData: {
          "trainee_id": traineeId,
          "user_id": createdUserId,
          "birthday_date": dto.birthdayDate,
        },
      );

      await db.commit();

      return await getById(traineeId);
    } catch (e) {
      if (db != null) await db.rollback();

      if (createdUserId != null) {
        await _remoteUserService.deleteUserAsAdmin(createdUserId);
      }

      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputTraineeDao>> update(
    String traineeId,
    UpdateTraineeDto dto,
  ) async {
    MysqlUtils? db;
    try {
      final res = await getById(traineeId);

      if (res.isFailure)
        return Result.failure(
          AppError(
            AppErrorType.notFound,
            "Couldn't find the trainee with provided trainee id",
            details: {...(res.error?.details ?? {})},
          ),
        );

      final isUserUpdated = await _remoteUserService.updateUser(
        res.data!.id,
        dto,
      );

      if (isUserUpdated.isFailure)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Failed to update trainee user data",
            details: {"error": isUserUpdated.error},
          ),
        );

      db = await MysqlConfiguration.getConnection();
      await db.startTrans();

      final traineeData = <String, dynamic>{};
      if (dto.birthdayDate != null)
        traineeData["birthday_date"] = dto.birthdayDate;

      if (traineeData.isNotEmpty) {
        await db.update(
          table: table,
          updateData: traineeData,
          where: {"trainee_id": traineeId},
        );
      }

      await db.commit();

      return await getById(traineeId);
    } catch (e) {
      if (db != null) {
        try {
          await db.rollback();
        } catch (_) {}
      }
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputTraineeDao>> delete(String id) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(id);
      if (existingRes.isFailure) return existingRes;

      final existing = existingRes.data!;

      final deleteAuthRes = await _remoteUserService.deleteUserAsAdmin(
        existing.id,
      );

      if (deleteAuthRes.isFailure) return Result.failure(deleteAuthRes.error!);

      db = await MysqlConfiguration.getConnection();

      await db.startTrans();

      await db.delete(table: table, where: {"trainee_id": id});
      await db.delete(table: userTable, where: {"id": existing.id});

      await db.commit();

      return existingRes;
    } catch (e) {
      if (db != null) await db.rollback();

      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  Future<Result<List<int>>> generateTraineePdf(String traineeId) async {
    try {
      final db = await MysqlConfiguration.connect();

      final traineeData = await db.query(
        """
      SELECT u.name, u.email, u.username, u.image, t.birthday_date, t.trainee_id 
      FROM trainees t 
      JOIN user u ON t.user_id = u.id 
      WHERE t.trainee_id = ?
      """,
        whereValues: [traineeId],
        isStmt: true,
      );

      if (traineeData.numOfRows == 0) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Formando não encontrado"),
        );
      }

      final gradesData = await db.query(
        """
      SELECT c.name as course, m.name as module, g.grade, g.created_at
      FROM grades g
      JOIN classes_modules cm ON g.class_module_id = cm.classes_modules_id
      JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
      JOIN modules m ON crm.module_id = m.module_id
      JOIN classes cls ON cm.class_id = cls.class_id
      JOIN courses c ON cls.course_id = c.course_id
      WHERE g.trainee_id = ?
      ORDER BY g.created_at DESC
      """,
        whereValues: [traineeId],
        isStmt: true,
      );

      double sumGrades = 0;
      int totalModules = 0;

      final List<List<String>> tableData = [];

      for (var row in gradesData.rows) {
        final gradeVal = double.tryParse(row['grade'].toString()) ?? 0.0;
        sumGrades += gradeVal;
        totalModules++;

        tableData.add([
          row['course'].toString(),
          row['module'].toString(),
          row['created_at'].toString().split(' ')[0],
          gradeVal.toStringAsFixed(2),
        ]);
      }

      final double average = totalModules > 0 ? sumGrades / totalModules : 0.0;
      final user = traineeData.rows.first;
      final now = DateTime.now();
      final dateFormatted =
          "${now.day}/${now.month}/${now.year} às ${now.hour}:${now.minute}";

      pw.ImageProvider? profileImage;
      final imagePath = user['image']?.toString();

      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          final cleanPath = imagePath.startsWith('/')
              ? imagePath.substring(1)
              : imagePath;
          final imageUrl = "http://localhost:8080/$cleanPath";

          final response = await dio.get(
            imageUrl,
            options: Options(responseType: ResponseType.bytes),
          );

          if (response.statusCode == 200) {
            profileImage = pw.MemoryImage(response.data);
            print(response.data);
          }
        } catch (e) {
          print("Erro ao processar imagem do formando com Dio: $e");
        }
      }

      final pdf = pw.Document();
      final baseColor = PdfColors.blue900;
      final lightColor = PdfColors.grey200;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),

          header: (context) => pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "INNOVACAD",
                    style: pw.TextStyle(
                      color: baseColor,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  pw.Text(
                    "Exportado em: $dateFormatted",
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Divider(color: baseColor, thickness: 2),
              pw.SizedBox(height: 20),
            ],
          ),

          footer: (context) => pw.Column(
            children: [
              pw.Divider(color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Innovacad Training Center",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    "Página ${context.pageNumber} de ${context.pagesCount}",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          build: (pw.Context context) => [
            pw.Center(
              child: pw.Text(
                "FICHA TÉCNICA DO FORMANDO",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 30),

            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: lightColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 60,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: baseColor, width: 2),
                    ),
                    child: profileImage != null
                        ? pw.ClipOval(
                            child: pw.Image(profileImage, fit: pw.BoxFit.cover),
                          )
                        : pw.Center(
                            child: pw.Text(
                              user['name']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: baseColor,
                              ),
                            ),
                          ),
                  ),
                  pw.SizedBox(width: 20),

                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          user['name'].toString(),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        _buildInfoRow("Email:", user['email'].toString()),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            _buildInfoRow("ID:", user['trainee_id'].toString()),
                            pw.SizedBox(width: 15),
                            _buildInfoRow(
                              "Data Nasc.:",
                              user['birthday_date'].toString().split(' ')[0],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: baseColor),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(5),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Módulos Concluídos: $totalModules"),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Text(
                            "Média Global: ",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            average.toStringAsFixed(2),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: average >= 10
                                  ? PdfColors.green700
                                  : PdfColors.red700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              "Histórico Académico e Avaliações",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              context: context,
              border: null,
              headerDecoration: pw.BoxDecoration(color: baseColor),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              headers: ['Curso', 'Módulo', 'Data Avaliação', 'Nota Final'],
              data: tableData,
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FixedColumnWidth(80),
                3: const pw.FixedColumnWidth(60),
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
            ),

            if (tableData.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 20),
                child: pw.Center(
                  child: pw.Text(
                    "Sem registos académicos disponíveis.",
                    style: pw.TextStyle(
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

      return Result.success(await pdf.save());
    } catch (e) {
      print("Erro ao gerar PDF Formando: $e");
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: "$label ",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TextSpan(text: value),
        ],
      ),
    );
  }
}
