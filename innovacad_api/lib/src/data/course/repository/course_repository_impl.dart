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

      final courses = results.map((row) {
        return OutputCourseDao(
          courseId: row["id"].toString(), // Assuming 'id' is the column name
          identifier: row["identifier"],
          name: row["name"],
        );
      }).toList();

      return Result.success(courses);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputCourseDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});

      if (result.isEmpty) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Course not found"),
        );
      }

      final dao = OutputCourseDao(
        courseId: result["id"].toString(),
        identifier: result["identifier"],
        name: result["name"],
      );

      return Result.success(dao);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputCourseDao>> create(CreateCourseDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      await db.insert(
        table: table,
        insertData: {"identifier": dto.identifier, "name": dto.name},
      );

      // MysqlUtils insert usually returns void or boolean?
      // Need to fetch the created item to get ID.
      // Assuming identifier is unique? Or get the last inserted.
      // MysqlUtils doesn't easily return last ID unless we query.
      // Let's query by identifier assuming uniqueness, or identifier+name if needed.

      final created = await db.getOne(
        table: table,
        where: {"identifier": dto.identifier},
      );

      if (created.isEmpty) {
        // Fallback or error?
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created course could not be retrieved",
          ),
        );
      }

      return Result.success(
        OutputCourseDao(
          courseId: created["id"].toString(),
          identifier: created["identifier"],
          name: created["name"],
        ),
      );
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputCourseDao>> update(String id, UpdateCourseDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final updateData = <String, dynamic>{};
      if (dto.identifier != null) updateData["identifier"] = dto.identifier;
      if (dto.name != null) updateData["name"] = dto.name;

      if (updateData.isEmpty) {
        return getById(id); // No changes
      }

      await db.update(table: table, updateData: updateData, where: {"id": id});

      return getById(id);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputCourseDao>> delete(String id) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(id);
      if (existingRes.isFailure) return existingRes;

      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": id});

      return existingRes;
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
