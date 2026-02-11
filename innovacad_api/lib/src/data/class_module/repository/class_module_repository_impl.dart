import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ClassModuleRepositoryImpl implements IClassModuleRepository {
  final String table = "classes_modules";

  @override
  Future<Result<List<OutputClassModuleDao>>> getAll() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.query("""
          SELECT 
            crm.courses_modules_id as courses_modules_id,
            cm.classes_modules_id as classes_modules_id,
            cm.class_id as class_id,
            t.trainer_id as trainer_id,
            u.name as trainer_name,
            m.duration as total_duration,
            m.name as module_name, 
            m.module_id as module_id,
            cm.current_duration as current_duration
          FROM classes_modules cm
          LEFT JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
          LEFT JOIN modules m ON crm.module_id = m.module_id
          LEFT JOIN trainers t ON cm.trainer_id = t.trainer_id
          LEFT JOIN user u ON t.user_id = u.id
          WHERE cm.classes_modules_id = ?
""");

        final items = results.rowsAssoc.map((data) {
          return OutputClassModuleDao.fromJson(data.assoc());
        }).toList();

        return Result.success(items);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the class modules...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> getById(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final query = """
          SELECT 
            crm.courses_modules_id as courses_modules_id,
            cm.classes_modules_id as classes_modules_id,
            cm.class_id as class_id,
            t.trainer_id as trainer_id,
            u.name as trainer_name,
            m.duration as total_duration,
            m.name as module_name, 
            m.module_id as module_id,
            cm.current_duration as current_duration
          FROM classes_modules cm
          LEFT JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
          LEFT JOIN modules m ON crm.module_id = m.module_id
          LEFT JOIN trainers t ON cm.trainer_id = t.trainer_id
          LEFT JOIN user u ON t.user_id = u.id
          WHERE cm.classes_modules_id = ?
        """;

        final result = await db.query(query, whereValues: [id], isStmt: true);

        if (result.numOfRows == 0) {
          return Result.failure(
            AppError(AppErrorType.notFound, "ClassModule not found..."),
          );
        }

        return Result.success(
          OutputClassModuleDao.fromJson(result.rowsAssoc.first.assoc()),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the class module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> create(CreateClassModuleDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.getConnection();

      await db.insert(
        table: table,
        insertData: {
          "class_id": dto.classId,
          "courses_modules_id": dto.coursesModulesId,
          "current_duration": dto.currentDuration,
        },
      );

      final created =
          await db.getOne(
                table: table,
                where: {
                  "class_id": dto.classId,
                  "courses_modules_id": dto.coursesModulesId,
                  " current_duration": dto.currentDuration,
                },
              )
              as Map<String, dynamic>;

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created ClassModule could not be retrieved...",
          ),
        );

      return Result.success(OutputClassModuleDao.fromJson(created));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the Class Module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> update(
    String id,
    UpdateClassModuleDto dto,
  ) async {
    MysqlUtils? db;

    try {
      final existingClassModule = await getById(id);

      if (existingClassModule.isFailure || existingClassModule.data == null)
        return existingClassModule;

      db = await MysqlConfiguration.getConnection();

      final updateData = <String, dynamic>{};

      if (dto.classId != null &&
          dto.classId != existingClassModule.data!.coursesModulesId)
        updateData["class_id"] = dto.classId;

      if (dto.coursesModulesId != null &&
          dto.coursesModulesId != existingClassModule.data!.coursesModulesId)
        updateData["courses_modules_id"] = dto.coursesModulesId;

      if (dto.currentDuration != null &&
          dto.currentDuration != existingClassModule.data!.currentDuration)
        updateData["current_duration"] = dto.currentDuration;

      if (updateData.isEmpty) return existingClassModule;

      await db.update(
        table: table,
        updateData: updateData,
        where: {"classes_modules_id": id},
      );

      return await getById(id);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the Class Module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> delete(String id) async {
    MysqlUtils? db;
    try {
      final existingClassModule = await getById(id);

      if (existingClassModule.isFailure || existingClassModule.data == null)
        return existingClassModule;

      db = await MysqlConfiguration.getConnection();

      await db.delete(table: table, where: {"classes_modules_id": id});

      return existingClassModule;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the Class Module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }
}
