import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ClassRepositoryImpl implements IClassRepository {
  final String table = "classes";

  @override
  Future<Result<List<OutputClassDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final results = await db.getAll(table: table);

      final classes = results.map((data) {
        return OutputClassDao.fromJson(data);
      }).toList();

      return Result.success(classes);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the classes...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final result =
          await db.getOne(table: table, where: {"class_id": id})
              as Map<String, dynamic>;

      if (result.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "Class not found"),
        );

      return Result.success(OutputClassDao.fromJson(result));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the class...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> create(CreateClassDto dto) async {
    MysqlUtils? db;

    db = await MysqlConfiguration.connect();

    try {
      await db.startTrans();

      await db.insert(
        table: table,
        insertData: {
          "course_id": dto.courseId,
          "location": dto.location,
          "identifier": dto.identifier,
          "status": dto.status.name,
          "start_date_timestamp": dto.startDateTimestamp.toIso8601String(),
          "end_date_timestamp": dto.endDateTimestamp.toIso8601String(),
        },
        debug: true,
      );

      final created = await db.getOne(
        table: table,
        where: {"identifier": dto.identifier},
      );

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created class could not be retrieved",
          ),
        );

      await db.commit();

      return Result.success(
        OutputClassDao.fromJson(
          created
              .map((k, v) => MapEntry(k.toString(), v))
              .cast<String, dynamic>(),
        ),
      );
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the class...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> update(String id, UpdateClassDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final existingClass = await getById(id);

      if (existingClass.isFailure || existingClass.data == null)
        return existingClass;

      final updateData = <String, dynamic>{};

      if (dto.courseId != null && dto.courseId != existingClass.data!.courseId)
        updateData["course_id"] = dto.courseId;

      if (dto.location != null && dto.location != existingClass.data!.location)
        updateData["location"] = dto.location;

      if (dto.identifier != null &&
          dto.identifier != existingClass.data!.identifier)
        updateData["identifier"] = dto.identifier;

      if (dto.status != null && dto.status != existingClass.data!.status)
        updateData["status"] = dto.status.toString().split('.').last;

      if (dto.startDateTimestamp != null &&
          dto.startDateTimestamp != existingClass.data!.startDateTimestamp)
        updateData["start_date_timestamp"] = dto.startDateTimestamp!
            .toIso8601String();

      if (dto.endDateTimestamp != null &&
          dto.endDateTimestamp != existingClass.data!.endDateTimestamp)
        updateData["end_date_timestamp"] = dto.endDateTimestamp!
            .toIso8601String();

      if (updateData.isEmpty) return existingClass;

      await db.update(
        table: table,
        updateData: updateData,
        where: {"class_id": id},
      );

      return await getById(id);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the class...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingClass = await getById(id);

      if (existingClass.isFailure || existingClass.data == null)
        return existingClass;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"class_id": id});

      return existingClass;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the class...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }
}
