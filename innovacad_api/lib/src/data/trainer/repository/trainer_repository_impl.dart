import 'package:dio/dio.dart';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/core/extensions/mysql_utils_extension.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/trainer/dao/skills_output/skill_output_dao.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart' as v;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

@v.Repository()
class TrainerRepositoryImpl implements ITrainerRepository {
  final RemoteUserService _remoteUserService;
  final IModuleRepository _moduleRepository;
  final IClassRepository _classRepository;
  final Dio dio;
  final String table = "trainers";

  TrainerRepositoryImpl(
    this._remoteUserService,
    this._moduleRepository,
    this._classRepository,
    this.dio,
  );

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value.toString() == '1' || value.toString() == 'true';
  }

  @override
  Future<Result<List<OutputTrainerDao>>> getAll() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final query = """
          SELECT t.trainer_id, t.user_id, t.birthday_date, t.is_coordinator,
                 u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt, u.emailVerified 
          FROM `trainers` t 
          JOIN `user` u ON t.user_id = u.id
        """;
        final results = await db.query(query);
        final List<OutputTrainerDao> daos = [];

        for (var row in results.rows) {
          final skillQuery =
              "SELECT module_id, competence_level FROM trainer_skills WHERE trainer_id = ?";
          final skillResults = await db.query(
            skillQuery,
            whereValues: [row['trainer_id']],
            isStmt: true,
          );
          row['skills'] = skillResults.rows;

          final isCoordinator = _parseBool(row['is_coordinator']);
          print("COORDENAODR? $isCoordinator");
          row['is_coordinator'] = isCoordinator;

          if (isCoordinator) {
            final classResults = await db.query(
              "SELECT class_id FROM trainers_classes_coordinator WHERE trainer_id = ?",
              whereValues: [row['trainer_id']],
              isStmt: true,
            );
            row['coordinated_class_ids'] = classResults.rows
                .map((c) => c['class_id'].toString())
                .toList();
          } else {
            row['coordinated_class_ids'] = [];
          }

          daos.add(OutputTrainerDao.fromJson(row));
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
  Future<Result<OutputTrainerDao>> getById(String trainerId) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.query(
          "SELECT t.trainer_id, t.user_id, t.birthday_date, t.is_coordinator, u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt, u.emailVerified "
          "FROM `trainers` t JOIN `user` u ON t.user_id = u.id WHERE t.trainer_id = ? LIMIT 1",
          whereValues: [trainerId],
          isStmt: true,
        );

        if (results.rows.isEmpty)
          return Result.failure(
            AppError(AppErrorType.notFound, "Trainer not found"),
          );

        final trainerMap = Map<String, dynamic>.from(results.rows[0]);

        final isCoordinator = _parseBool(trainerMap['is_coordinator']);
        trainerMap['is_coordinator'] = isCoordinator;

        final skillResults = await db.query(
          "SELECT module_id, competence_level FROM trainer_skills WHERE trainer_id = ?",
          whereValues: [trainerId],
          isStmt: true,
        );
        trainerMap['skills'] = skillResults.rows;

        if (isCoordinator) {
          final classResults = await db.query(
            "SELECT class_id FROM trainers_classes_coordinator WHERE trainer_id = ?",
            whereValues: [trainerId],
            isStmt: true,
          );
          trainerMap['coordinated_class_ids'] = classResults.rows
              .map((c) => c['class_id'].toString())
              .toList();
        } else {
          trainerMap['coordinated_class_ids'] = [];
        }

        print("TRAINER MAP::: $trainerMap");

        return Result.success(OutputTrainerDao.fromJson(trainerMap));
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
  Future<Result<OutputTrainerDao>> create(CreateTrainerDto dto) async {
    MysqlUtils? db;
    String? createdUserId;

    print("TRAINER DTO::: ${dto.toJson()}");

    try {
      final bool hasClassesToCoordinate =
          dto.classIds != null && dto.classIds!.isNotEmpty;
      final bool isCoordinator =
          hasClassesToCoordinate || (dto.isCoordinator == true);
      final String userRole = isCoordinator ? "coordinator" : "trainer";

      final responseUser = await _remoteUserService.signUpUser(
        dto.email,
        dto.name,
        dto.password,
        dto.username,
      );
      if (responseUser.isFailure) return Result.failure(responseUser.error!);

      final userData = responseUser.data as Map<String, dynamic>;
      createdUserId = userData["id"];

      db = await MysqlConfiguration.getConnection();

      return await db.transaction((txn) async {
        final userCheck = await txn.query(
          "SELECT id FROM user WHERE id = ?",
          whereValues: [createdUserId],
          isStmt: true,
        );

        if (userCheck.numOfRows == 0) {
          await txn.insert(
            table: "user",
            insertData: {
              "id": createdUserId,
              "username": dto.username,
              "name": dto.name,
              "email": dto.email,
              "role": userRole,
              "createdAt": DateTime.now().toIso8601String(),
              "emailVerified": 0,
            },
          );
        }

        final trainerId = const Uuid().v4();

        await txn.insert(
          table: table,
          insertData: {
            "trainer_id": trainerId,
            "user_id": createdUserId,
            "birthday_date": dto.birthdayDate,
            "is_coordinator": isCoordinator ? 1 : 0,
          },
        );

        if (dto.skillsToAdd != null) {
          for (var skill in dto.skillsToAdd!) {
            await txn.insert(
              table: "trainer_skills",
              insertData: {
                "trainer_id": trainerId,
                "module_id": skill.moduleId,
                "competence_level": skill.competenceLevel ?? 1,
              },
            );
          }
        }

        if (hasClassesToCoordinate) {
          for (var classId in dto.classIds!) {
            await txn.query(
              "INSERT INTO trainers_classes_coordinator (trainer_id, class_id) VALUES (?, ?)",
              whereValues: [trainerId, classId],
              isStmt: true,
            );
          }
        }

        final res = await getById(trainerId);
        print("Trainer::: ${res.data?.toJson()}");
        return res;
      });
    } catch (e, s) {
      if (createdUserId != null) {
        await _remoteUserService.deleteUserAsAdmin(createdUserId);
      }
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
  Future<Result<OutputTrainerDao>> update(
    String trainerId,
    UpdateTrainerDto dto,
  ) async {
    MysqlUtils? db;
    try {
      final res = await getById(trainerId);
      if (res.isFailure) return res;

      await _remoteUserService.updateUser(res.data!.id, dto);

      db = await MysqlConfiguration.getConnection();
      await db.startTrans();

      bool isCurrentlyCoordinator = _parseBool(res.data!.isCoordinator);

      final currentClassesQuery = await db.query(
        "SELECT COUNT(*) as total FROM trainers_classes_coordinator WHERE trainer_id = ?",
        whereValues: [trainerId],
        isStmt: true,
      );
      int currentClassCount = int.parse(
        currentClassesQuery.rows.first['total'].toString(),
      );

      int toAddCount = dto.classIdsToAdd?.length ?? 0;
      int toRemoveCount = dto.classIdsToRemove?.length ?? 0;

      int futureClassCount = currentClassCount + toAddCount - toRemoveCount;
      if (futureClassCount < 0) futureClassCount = 0;

      bool newIsCoordinatorState = isCurrentlyCoordinator;

      if (dto.isCoordinator != null) {
        newIsCoordinatorState = dto.isCoordinator!;
      }

      if (futureClassCount > 0) {
        newIsCoordinatorState = true;
      }

      if (newIsCoordinatorState != isCurrentlyCoordinator) {
        final newRole = newIsCoordinatorState ? "coordinator" : "trainer";

        await db.update(
          table: "user",
          updateData: {"role": newRole},
          where: {"id": res.data!.id},
        );

        await db.update(
          table: table,
          updateData: {"is_coordinator": newIsCoordinatorState ? 1 : 0},
          where: {"trainer_id": trainerId},
        );

        if (!newIsCoordinatorState) {
          await db.delete(
            table: "trainers_classes_coordinator",
            where: {"trainer_id": trainerId},
          );
        }
      }

      final updateData = <String, dynamic>{};
      if (dto.birthdayDate != null)
        updateData["birthday_date"] = dto.birthdayDate;

      if (updateData.isNotEmpty) {
        await db.update(
          table: table,
          updateData: updateData,
          where: {"trainer_id": trainerId},
        );
      }

      if (dto.skillsToRemove != null && dto.skillsToRemove!.isNotEmpty) {
        final ids = dto.skillsToRemove!
            .split(',')
            .map((e) => e.trim())
            .toList();
        final placeholders = ids.map((_) => "?").join(",");
        await db.query(
          "DELETE FROM trainer_skills WHERE trainer_id = ? AND module_id IN ($placeholders)",
          whereValues: [trainerId, ...ids],
          isStmt: true,
        );
      }
      if (dto.skillsToAdd != null) {
        for (var skill in dto.skillsToAdd!) {
          await db.query(
            "INSERT INTO trainer_skills (trainer_id, module_id, competence_level) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE competence_level = ?",
            whereValues: [
              trainerId,
              skill.moduleId,
              skill.competenceLevel ?? 1,
              skill.competenceLevel ?? 1,
            ],
            isStmt: true,
          );
        }
      }

      if (newIsCoordinatorState) {
        if (dto.classIdsToRemove != null && dto.classIdsToRemove!.isNotEmpty) {
          final placeholders = dto.classIdsToRemove!.map((_) => "?").join(",");
          await db.query(
            "DELETE FROM trainers_classes_coordinator WHERE trainer_id = ? AND class_id IN ($placeholders)",
            whereValues: [trainerId, ...dto.classIdsToRemove!],
            isStmt: true,
          );
        }

        if (dto.classIdsToAdd != null && dto.classIdsToAdd!.isNotEmpty) {
          for (var classId in dto.classIdsToAdd!) {
            await db.query(
              "INSERT IGNORE INTO trainers_classes_coordinator (trainer_id, class_id) VALUES (?, ?)",
              whereValues: [trainerId, classId],
              isStmt: true,
            );
          }
        }
      }

      await db.commit();
      return await getById(trainerId);
    } catch (e) {
      if (db != null) await db.rollback();
      print("🔥 [Update Error]: $e");
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputTrainerDao>> delete(String id) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(id);
      if (existingRes.isFailure) return existingRes;

      await _remoteUserService.deleteUserAsAdmin(existingRes.data!.id);

      db = await MysqlConfiguration.getConnection();
      await db.startTrans();

      await db.delete(table: "user", where: {"id": existingRes.data!.id});

      await db.commit();
      return existingRes;
    } catch (e) {
      if (db != null) await db.rollback();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<List<int>>> generateTrainerPdf(String trainerId) async {
    try {
      final db = await MysqlConfiguration.connect();

      final trainerData = await db.query(
        """
      SELECT u.name, u.email, u.username, u.image, t.birthday_date, t.trainer_id, t.is_coordinator
      FROM trainers t 
      JOIN user u ON t.user_id = u.id 
      WHERE t.trainer_id = ?
      """,
        whereValues: [trainerId],
        isStmt: true,
      );

      if (trainerData.numOfRows == 0) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Formador não encontrado"),
        );
      }

      final teachingHistory = await db.query(
        """
      SELECT 
        c.name as course_name,
        cls.identifier as class_ref,
        m.name as module_name,
        SUM(s.total_hours) as total_hours_taught,
        MIN(s.start_date_timestamp) as first_class,
        MAX(s.end_date_timestamp) as last_class
      FROM schedules s
      JOIN classes_modules cm ON s.class_module_id = cm.classes_modules_id
      JOIN classes cls ON cm.class_id = cls.class_id
      JOIN courses c ON cls.course_id = c.course_id
      JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
      JOIN modules m ON crm.module_id = m.module_id
      WHERE s.trainer_id = ?
      GROUP BY cls.class_id, m.module_id
      ORDER BY last_class DESC
      """,
        whereValues: [trainerId],
        isStmt: true,
      );

      final user = trainerData.rows.first;
      final now = DateTime.now();
      final dateFormatted = "${now.day}/${now.month}/${now.year}";

      double grandTotalHours = 0;

      final List<List<String>> tableData = [];

      for (var row in teachingHistory.rows) {
        final hours =
            double.tryParse(row['total_hours_taught'].toString()) ?? 0.0;
        grandTotalHours += hours;

        String startStr = row['first_class'].toString().split(' ')[0];
        String endStr = row['last_class'].toString().split(' ')[0];

        tableData.add([
          row['class_ref'].toString(),
          row['course_name'].toString(),
          row['module_name'].toString(),
          "$startStr a $endStr",
          "${hours.toStringAsFixed(1)} h",
        ]);
      }

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
          }
        } catch (e) {
          print("Erro ao processar imagem com Dio: $e");
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
                    "Ficha de Formador",
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Divider(color: baseColor, thickness: 2),
              pw.SizedBox(height: 20),
            ],
          ),

          footer: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Gerado a $dateFormatted",
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                "Página ${context.pageNumber} de ${context.pagesCount}",
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),

          build: (context) => [
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
                        pw.Text(user['email'].toString()),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text(
                              "Username: ",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(user['username'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  "Total Horas Lecionadas: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "${grandTotalHours.toStringAsFixed(1)} h",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: baseColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              context: context,
              border: null,
              headerDecoration: pw.BoxDecoration(color: baseColor),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 5,
              ),
              headers: ['Turma', 'Curso', 'Módulo', 'Período', 'Horas'],
              data: tableData,
              columnWidths: {
                0: const pw.FixedColumnWidth(60),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FixedColumnWidth(110),
                4: const pw.FixedColumnWidth(50),
              },
              cellAlignments: {4: pw.Alignment.centerRight},
            ),
          ],
        ),
      );

      return Result.success(await pdf.save());
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<List<SkillOutputDao>>> getSkills(String id) async {
    try {
      final trainer = await getById(id);

      if (trainer.isFailure || trainer.data?.skills == null)
        return Result.failure(
          AppError(AppErrorType.notFound, "Trainer not found!"),
        );

      List<SkillOutputDao> skills = [];

      if (trainer.data?.skills != null) {
        for (var skill in trainer.data!.skills) {
          final module = await _moduleRepository.getById(skill.moduleId);

          if (module.isSuccess) {
            skills.add(
              SkillOutputDao(
                name: module.data!.name,
                competenceLevel: skill.competenceLevel,
              ),
            );
          }
        }
      }

      return Result.success(skills);
    } catch (e) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to fetch trainer skills!",
          details: {"error": e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<String>>> getCoordinatedClasses(String id) async {
    try {
      final trainer = await getById(id);

      if (trainer.isFailure || trainer.data?.coordinatedClassIds == null)
        return Result.failure(
          AppError(AppErrorType.notFound, "Trainer not found!"),
        );

      List<String> classes = [];

      if (trainer.data?.coordinatedClassIds != null) {
        for (var id in trainer.data!.coordinatedClassIds!) {
          final klass = await _classRepository.getById(id);

          if (klass.isSuccess) {
            classes.add("${klass.data?.identifier} - ${klass.data?.location}");
          }
        }
      }

      return Result.success(classes);
    } catch (e) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to fetch class skills!",
          details: {"error": e.toString()},
        ),
      );
    }
  }

  @override
  Future<bool> isCoordinatorOfClass(String trainerId, String classId) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final result = await db.query(
          "SELECT 1 FROM trainers_classes_coordinator WHERE trainer_id = ? AND class_id = ? LIMIT 1",
          whereValues: [trainerId, classId],
          isStmt: true,
        );
        return result.numOfRows > 0;
      });
    } catch (e) {
      print("Error checking coordination: $e");
      return false;
    }
  }
}
