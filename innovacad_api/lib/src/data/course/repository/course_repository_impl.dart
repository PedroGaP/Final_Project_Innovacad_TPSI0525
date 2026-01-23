import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/course/repository/i_course_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class CourseRepositoryImpl implements ICourseRepository {
  final String table = "courses";

  @override
  Future<Result<List<OutputCourseDao>>> getAll() async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final results = await db.getAll(table: table);

      final courses = results.map((data) {
        return OutputCourseDao.fromJson(data);
      }).toList();

      return Result.success(courses);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the courses...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final result =
          await db.getOne(table: table, where: {"course_id": id})
              as Map<String, dynamic>;

      if (result.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "Course not found"),
        );

      return Result.success(OutputCourseDao.fromJson(result));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the course...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseDao>> create(CreateCourseDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      db.startTrans();

      await db.insert(
        table: table,
        insertData: {"identifier": dto.identifier, "name": dto.name},
      );

      final created =
          await db.getOne(
                table: table,
                where: {"identifier": dto.identifier, "name": dto.name},
              )
              as Map<String, dynamic>;

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created course could not be retrieved",
          ),
        );

      db.commit();

      return Result.success(OutputCourseDao.fromJson(created));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the course...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseDao>> update(String id, UpdateCourseDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final existingCourse = await getById(id);

      if (existingCourse.isFailure || existingCourse.data == null)
        return existingCourse;

      final updateData = <String, dynamic>{};

      if (dto.identifier != null &&
          dto.identifier != existingCourse.data!.identifier)
        updateData["identifier"] = dto.identifier;

      if (dto.name != null && dto.name != existingCourse.data!.name)
        updateData["name"] = dto.name;

      if (updateData.isEmpty) return getById(id);

      await db.update(
        table: table,
        updateData: updateData,
        where: {"course_id": id},
      );

      return await getById(id);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the course...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingCourse = await getById(id);

      if (existingCourse.isFailure || existingCourse.data == null)
        return existingCourse;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"course_id": id});

      return existingCourse;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the course...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }
}
