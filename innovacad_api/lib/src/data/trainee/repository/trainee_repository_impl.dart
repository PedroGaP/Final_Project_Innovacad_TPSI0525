import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/core/extensions/mysql_utils_extension.dart';
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
            AppErrorType.conflict,
            "A trainee with the username or email provided already exists.",
          ),
        );
      }

      final responseUser = await _remoteUserService.signUpUser(
        dto.email,
        dto.name,
        dto.password,
        dto.username,
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

      final userData = responseUser.data as Map<String, dynamic>;
      createdUserId = userData["id"];
      final traineeId = Uuid().v4();

      await db.transaction((txn) async {
        final updateCount = await txn.update(
          table: "user",
          updateData: {"username": dto.username, "role": "trainee"},
          where: {"id": createdUserId},
        );

        if (updateCount <= BigInt.zero) {
          throw Exception("User update failed.");
        }

        await txn.insert(
          table: table,
          insertData: {
            "trainee_id": traineeId,
            "user_id": createdUserId,
            "birthday_date": dto.birthdayDate,
          },
          debug: false,
        );
      });

      return await getById(traineeId);
    } catch (e, _) {
      if (createdUserId != null) {
        try {
          await _remoteUserService.deleteUserAsAdmin(createdUserId);
        } catch (_) {}
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

      // 1. Buscar dados do Formando
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

      // 2. Buscar os Cursos (Enrollments) e a Média Final já calculada
      final enrollmentsData = await db.query(
        """
        SELECT c.course_id, c.name as course_name, e.final_grade
        FROM enrollments e
        JOIN classes cls ON e.class_id = cls.class_id
        JOIN courses c ON cls.course_id = c.course_id
        WHERE e.trainee_id = ?
        ORDER BY c.name ASC
        """,
        whereValues: [traineeId],
        isStmt: true,
      );

      // 3. Buscar todas as notas detalhadas dos módulos
      final gradesData = await db.query(
        """
        SELECT c.course_id, m.name as module, g.grade, g.created_at
        FROM grades g
        JOIN classes_modules cm ON g.class_module_id = cm.classes_modules_id
        JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
        JOIN modules m ON crm.module_id = m.module_id
        JOIN classes cls ON cm.class_id = cls.class_id
        JOIN courses c ON cls.course_id = c.course_id
        WHERE g.trainee_id = ? AND g.grade_type = 'final' AND g.status = 'finalized'
        ORDER BY g.created_at DESC
        """,
        whereValues: [traineeId],
        isStmt: true,
      );

      // 4. Estruturar os dados em memória (Agrupar por Curso)
      // Mapa: CourseID -> { Nome, NotaFinal, ListaDeModulos }
      Map<String, Map<String, dynamic>> coursesMap = {};

      // Inicializar com os enrollments
      for (var row in enrollmentsData.rows) {
        final courseId = row['course_id'].toString();
        coursesMap[courseId] = {
          'course_name': row['course_name'],
          'final_grade': double.tryParse(row['final_grade'].toString()) ?? 0.0,
          'modules': <List<String>>[], // Lista para a tabela do PDF
        };
      }

      // Preencher com as notas dos módulos
      for (var row in gradesData.rows) {
        final courseId = row['course_id'].toString();
        final gradeVal = double.tryParse(row['grade'].toString()) ?? 0.0;

        // Só adiciona se o curso existir nos enrollments (segurança)
        if (coursesMap.containsKey(courseId)) {
          coursesMap[courseId]!['modules'].add([
            row['module'].toString(),
            row['created_at'].toString().split(' ')[0], // Data
            gradeVal.toStringAsFixed(2), // Nota
          ]);
        }
      }

      // 5. Preparação para o PDF
      final user = traineeData.rows.first;
      final now = DateTime.now();
      final dateFormatted =
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} às ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      pw.ImageProvider? profileImage;
      final imagePath = user['image']?.toString();
      if (imagePath != null && imagePath.isNotEmpty && imagePath != 'null') {
        profileImage = await _loadProfileImage(imagePath);
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
          build: (pw.Context context) {
            return [
              // Cabeçalho do Formando
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: lightColor,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: baseColor, width: 2),
                      ),
                      child: profileImage != null
                          ? pw.ClipOval(
                              child: pw.Image(
                                profileImage,
                                fit: pw.BoxFit.cover,
                              ),
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
                    pw.SizedBox(width: 15),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            user['name'].toString(),
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            user['email'].toString(),
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Título
              pw.Text(
                "Histórico Académico por Curso",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),

              // Se não houver cursos
              if (coursesMap.isEmpty)
                pw.Center(
                  child: pw.Text(
                    "O formando não está inscrito em nenhum curso.",
                  ),
                ),

              // Loop para gerar uma tabela por cada curso
              ...coursesMap.values.map((courseData) {
                final modules = courseData['modules'] as List<List<String>>;
                final finalGrade = courseData['final_grade'] as double;
                final courseName = courseData['course_name'];

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 25),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Nome do Curso e Média
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          border: pw.Border(
                            left: pw.BorderSide(color: baseColor, width: 4),
                          ),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              courseName,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            pw.Row(
                              children: [
                                pw.Text("Média Final: "),
                                pw.Text(
                                  finalGrade.toStringAsFixed(2),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: finalGrade >= 10
                                        ? PdfColors.green700
                                        : PdfColors.red700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 8),

                      // Tabela de Módulos deste curso
                      if (modules.isEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 10),
                          child: pw.Text(
                            "Sem notas lançadas neste curso.",
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        )
                      else
                        pw.TableHelper.fromTextArray(
                          context: context,
                          border: null,
                          headerDecoration: const pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          headerStyle: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          rowDecoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                color: PdfColors.grey300,
                                width: 0.5,
                              ),
                            ),
                          ),
                          cellPadding: const pw.EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          cellStyle: const pw.TextStyle(fontSize: 10),
                          headers: ['Módulo', 'Data', 'Nota'],
                          data: modules,
                          columnWidths: {
                            0: const pw.FlexColumnWidth(4),
                            1: const pw.FlexColumnWidth(2),
                            2: const pw.FlexColumnWidth(1),
                          },
                          cellAlignments: {
                            0: pw.Alignment.centerLeft,
                            1: pw.Alignment.center,
                            2: pw.Alignment.centerRight,
                          },
                        ),
                    ],
                  ),
                );
              }).toList(),
            ];
          },
        ),
      );

      return Result.success(await pdf.save());
    } catch (e, s) {
      print(s);
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  Future<pw.ImageProvider?> _loadProfileImage(String imagePath) async {
    try {
      if (!imagePath.startsWith('http')) {
        final cleanPath = imagePath.startsWith('/')
            ? imagePath.substring(1)
            : imagePath;

        final file = File(cleanPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return pw.MemoryImage(bytes);
        }

        final fileFromPublic = File('public/$cleanPath');
        if (await fileFromPublic.exists()) {
          final bytes = await fileFromPublic.readAsBytes();
          return pw.MemoryImage(bytes);
        }
      }

      print(imagePath);

      final imageUrl = imagePath.startsWith('http')
          ? imagePath
          : "http://localhost:8080/resource/$imagePath";

      print(imageUrl);

      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data is List<int>) {
        return pw.MemoryImage(Uint8List.fromList(response.data));
      }
    } catch (_) {}

    return null;
  }
}
