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
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final results = await db.getAll(table: table);

      final items = results.map((data) {
        return OutputClassModuleDao.fromJson(data);
      }).toList();

      return Result.success(items);
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
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final result =
          await db.getOne(table: table, where: {"classes_modules_id": id})
              as Map<String, dynamic>;

      if (result.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "ClassModule not found..."),
        );

      return Result.success(OutputClassModuleDao.fromJson(result));
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
      db = await MysqlConfiguration.connect();

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
                  "current_duration": dto.currentDuration,
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
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> update(
    String id,
    UpdateClassModuleDto dto,
  ) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final existingClassModule = await getById(id);

      if (existingClassModule.isFailure || existingClassModule.data == null)
        return existingClassModule;

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
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> delete(String id) async {
    MysqlUtils? db;
    try {
      final existingClassModule = await getById(id);

      if (existingClassModule.isFailure || existingClassModule.data == null)
        return existingClassModule;

      db = await MysqlConfiguration.connect();

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
    }
  }
}
