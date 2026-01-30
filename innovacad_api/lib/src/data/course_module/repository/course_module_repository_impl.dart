import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class CourseModuleRepositoryImpl implements ICourseModuleRepository {
  final String table = "courses_modules";

  @override
  Future<Result<List<OutputCourseModuleDao>>> getAll() async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final results = await db.getAll(table: table);

      final items = results.map((data) {
        return OutputCourseModuleDao.fromJson(data);
      }).toList();

      return Result.success(items);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the course modules...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseModuleDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final result =
          await db.getOne(table: table, where: {"courses_modules_id": id})
              as Map<String, dynamic>;

      if (result.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "CourseModule not found"),
        );

      return Result.success(OutputCourseModuleDao.fromJson(result));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the course module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseModuleDao>> create(
    CreateCourseModuleDto dto,
  ) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      await db.startTrans();

      await db.insert(
        table: table,
        insertData: {
          "course_id": dto.courseId,
          "module_id": dto.moduleId,
          "sequence_course_module_id": dto.sequenceCourseModuleId,
        },
      );

      final created =
          await db.getOne(
                table: table,
                where: {"course_id": dto.courseId, "module_id": dto.moduleId},
              )
              as Map<String, dynamic>;

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created course module could not be retrieved",
          ),
        );

      return Result.success(OutputCourseModuleDao.fromJson(created));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the course module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseModuleDao>> update(
    String id,
    UpdateCourseModuleDto dto,
  ) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final existingCourseModule = await getById(id);

      if (existingCourseModule.isFailure || existingCourseModule.data == null)
        return existingCourseModule;

      final updateData = <String, dynamic>{};

      if (dto.courseId != null &&
          dto.courseId != existingCourseModule.data!.coursesModulesId)
        updateData["course_id"] = dto.courseId;

      if (dto.moduleId != null &&
          dto.moduleId != existingCourseModule.data!.moduleId)
        updateData["module_id"] = dto.moduleId;

      if (dto.sequenceCourseModuleId != null &&
          dto.sequenceCourseModuleId !=
              existingCourseModule.data!.sequenceCourseModuleId)
        updateData["sequence_course_module_id"] = dto.sequenceCourseModuleId;

      if (updateData.isEmpty) return existingCourseModule;

      await db.update(
        table: table,
        updateData: updateData,
        where: {"courses_modules_id": id},
      );

      return await getById(id);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the course module...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseModuleDao>> delete(String id) async {
    MysqlUtils? db;
    try {
      final existingCourseModule = await getById(id);

      if (existingCourseModule.isFailure || existingCourseModule.data == null)
        return existingCourseModule;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"courses_modules_idid": id});

      return existingCourseModule;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the course module...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }
}
