import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/grade/dto/batch/batch_grade_dto.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Repository()
class GradeRepositoryImpl implements IGradeRepository {
  final String table = "grades";
  final IClassModuleRepository _classModuleRepository;

  GradeRepositoryImpl(this._classModuleRepository);

  @override
  Future<Result<List<OutputGradeDao>>> getAll() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final result = await db.query("""
          SELECT g.class_module_id,
              crm.module_id,
              g.trainee_id,
              g.grade,
              g.grade_type,
              g.status,
              g.created_at,
              g.updated_at
          FROM grades g
          JOIN classes_modules cm ON g.class_module_id = cm.classes_modules_id
          JOIN courses_modules crm USING(courses_modules_id);
        """);
        final grades = result.rowsAssoc
            .map((data) => OutputGradeDao.fromJson(data.assoc()))
            .toList();
        return Result.success(grades);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error while fetching grades",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputGradeDao>> getById(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final result = await db.query(
          """
          SELECT g.class_module_id,
              crm.module_id,
              g.trainee_id,
              g.grade,
              g.grade_type,
              g.status,
              g.created_at,
              g.updated_at
          FROM grades g
          JOIN classes_modules cm ON g.class_module_id = cm.classes_modules_id
          JOIN courses_modules crm USING(courses_modules_id)
          WHERE g.grade_id = ?;
        """,
          whereValues: [id],
          isStmt: true,
        );
        if (result.numOfRows == 0)
          return Result.failure(
            AppError(AppErrorType.notFound, "Grade not found"),
          );
        return Result.success(
          OutputGradeDao.fromJson(result.rowsAssoc.first.assoc()),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error while fetching grade with id '$id'",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<OutputGradeDao>>> getByClassModule(
    String classModuleId,
  ) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final res = await db.query(
          """
            SELECT
              g.grade_id as grade_id,
              g.class_module_id as class_module_id,
              crm.module_id as module_id,
              g.trainee_id as trainee_id,
              g.grade as grade,
              g.grade_type as grade_type,
              g.status as status,
              g.created_at as created_at,
              g.updated_at as updated_at
            FROM grades g
            JOIN classes_modules cm ON g.class_module_id = cm.classes_modules_id
            JOIN courses_modules crm USING (courses_modules_id)
            WHERE cm.classes_modules_id = ?;
          """,
          whereValues: [classModuleId],
          isStmt: true,
        );

        if (res.numOfRows == 0) return Result.success([]);

        return Result.success(
          res.rowsAssoc.map((r) => OutputGradeDao.fromJson(r.assoc())).toList(),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error while fetching grades by class module id '$classModuleId'",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }

  @override
  Future<bool> canEditGrades({
    required String userId,
    required String userRole,
    required String classModuleId,
  }) async {
    if (userRole == 'admin') return true;

    final db = await MysqlConfiguration.getConnection();
    try {
      final statusCheck = await db.query(
        "SELECT status FROM grades WHERE class_module_id = ? LIMIT 1",
        whereValues: [classModuleId],
        isStmt: true,
      );

      if (statusCheck.numOfRows > 0) {
        final status = statusCheck.rows.first['status'];
        if (status == 'finalized' && userRole != 'admin') {
          return false;
        }
      }

      if (userRole == 'trainer') {
        final trainerCheck = await db.query(
          """
          SELECT 1 FROM classes_modules cm
          JOIN trainers t ON cm.trainer_id = t.trainer_id
          WHERE cm.classes_modules_id = ? AND t.user_id = ?
          """,
          whereValues: [classModuleId, userId],
          isStmt: true,
        );
        return trainerCheck.numOfRows > 0;
      }

      return false;
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<bool> canFinalizeGrades({
    required String userId,
    required String userRole,
    required String classModuleId,
  }) async {
    if (['admin', 'assistant'].contains(userRole)) return true;

    if (userRole != 'coordinator') return false;

    final db = await MysqlConfiguration.getConnection();
    try {
      final coordCheck = await db.query(
        """
        SELECT 1 
        FROM trainers_classes_coordinator tcc
        JOIN trainers t ON tcc.trainer_id = t.trainer_id
        JOIN classes_modules cm ON tcc.class_id = cm.class_id
        WHERE cm.classes_modules_id = ? AND t.user_id = ?
        """,
        whereValues: [classModuleId, userId],
        isStmt: true,
      );

      return coordCheck.numOfRows > 0;
    } catch (e) {
      print("Error checking finalize permission: $e");
      return false;
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<bool>> batchUpsert(
    BatchGradeDto dto,
    ExtendedUserDetails user,
  ) async {
    MysqlUtils? db;
    try {
      if (dto.grades.isEmpty) return Result.success(true);

      db = await MysqlConfiguration.getConnection();

      final moduleRes = await _classModuleRepository.getById(dto.classModuleId);
      if (moduleRes.isFailure) return Result.failure(moduleRes.error!);

      final moduleData = moduleRes.data!;
      bool hasPermission = false;
      print("CLASS ID: ${moduleData.classId}");
      print("USER ID: ${user.id}");
      print("TRAINER ID: ${user.trainerId}");
      print("ROLE: ${user.roles.first}");

      if (['admin', 'assistant'].contains(user.roles.first)) {
        hasPermission = true;
      } else if (moduleData.trainerId == user.id ||
          moduleData.trainerId == user.trainerId) {
        hasPermission = true;
      } else if (user.roles.first == 'coordinator') {
        if (user.trainerId != null) {
          final isCoord = await _checkCoordination(
            user.trainerId!,
            moduleData.classId,
          );
          if (isCoord) hasPermission = true;
        }
      }

      if (!hasPermission) {
        return Result.failure(
          AppError(
            AppErrorType.forbidden,
            "You do not have permission to edit grades for this module.",
          ),
        );
      }

      final values = <String>[];
      final uuid = Uuid();

      for (var item in dto.grades) {
        final gradeId = uuid.v4();
        values.add(
          "('$gradeId', '${dto.classModuleId}', '${item.traineeId}', ${item.grade}, '${item.gradeType}', 'draft')",
        );
      }

      final sql =
          """
        INSERT INTO grades (grade_id, class_module_id, trainee_id, grade, grade_type, status)
        VALUES ${values.join(',')}
        ON DUPLICATE KEY UPDATE 
          grade = VALUES(grade),
          updated_at = CURRENT_TIMESTAMP
      """;

      await db.query(sql);

      return Result.success(true);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error batch upsert grades",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<bool>> finalizeGrades(String classModuleId) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.getConnection();
      await db.query(
        "UPDATE grades SET status = 'finalized' WHERE class_module_id = ?",
        whereValues: [classModuleId],
        isStmt: true,
      );
      return Result.success(true);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error while finalizing grades from class module '$classModuleId'",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final id = Uuid().v4();
        await db.insert(
          table: table,
          insertData: {
            "grade_id": id,
            "class_module_id": dto.classModuleId,
            "trainee_id": dto.traineeId,
            "grade": dto.grade,
            "grade_type": dto.gradeType,
            "status": dto.status ?? 'draft',
          },
        );

        final res = await getById(id);
        return Result.success(
          OutputGradeDao.fromJson(res as Map<String, dynamic>),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error while creating grade",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputGradeDao>> update(String id, UpdateGradeDto dto) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        if (dto.grade != null) {
          await db.update(
            table: table,
            where: {'grade_id': id},
            updateData: {'grade': dto.grade},
          );
        }
        final res = await getById(id);
        return res;
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error while updating grade with id '$id'",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputGradeDao>> delete(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        await db.delete(table: table, where: {'grade_id': id});
        return Result.success(
          OutputGradeDao(
            gradeId: id,
            classModuleId: '',
            moduleId: '',
            traineeId: '',
            grade: 0,
            gradeType: '',
            status: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error while deleting grade with id '$id'",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }

  Future<bool> _checkCoordination(String trainerId, String classId) async {
    final db = await MysqlConfiguration.getConnection();
    try {
      final result = await db.query(
        "SELECT 1 FROM trainers_classes_coordinator WHERE trainer_id = ? AND class_id = ?",
        whereValues: [trainerId, classId],
        isStmt: true,
      );
      return result.numOfRows > 0;
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  Future<Result<List<OutputGradeDao>>> fetchGradesByTraineeId(
    String traineeId,
  ) async {
    final db = await MysqlConfiguration.getConnection();
    try {
      final result = await db.query(
        """
          SELECT g.class_module_id as class_module_id,
              crm.module_id as module_id,
              g.trainee_id as trainee_id,
              g.grade as grade,
              g.grade_type as grade_type,
              g.status as status,
              g.created_at as created_at,
              g.updated_at as updated_at,
              g.grade_id as grade_id
          FROM grades g
          JOIN classes_modules cm ON g.class_module_id = cm.classes_modules_id
          JOIN courses_modules crm USING(courses_modules_id)
          WHERE trainee_id = ?;
        """,
        whereValues: [traineeId],
        isStmt: true,
      );

      if (result.numOfRows == 0) {
        return Result.success([]);
      }

      final grades = result.rowsAssoc
          .map((data) => OutputGradeDao.fromJson(data.assoc()))
          .toList();
      return Result.success(grades);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to fetch trainee grades",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }
}
