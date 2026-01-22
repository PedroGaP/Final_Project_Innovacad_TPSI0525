import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class EnrollmentRepositoryImpl implements IEnrollmentRepository {
  final String table = "enrollments";

  @override
  Future<Result<List<OutputEnrollmentDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final results = await db.getAll(table: table);

      final items = results.map((row) {
        return OutputEnrollmentDao(
          enrollmentId: row["id"].toString(),
          classId: row["class_id"].toString(),
          traineeId: row["trainee_id"].toString(),
          finalGrade: row["final_grade"] is num
              ? (row["final_grade"] as num).toDouble()
              : double.parse(row["final_grade"].toString()),
        );
      }).toList();

      return Result.success(items);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputEnrollmentDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});

      if (result.isEmpty) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Enrollment not found"),
        );
      }

      final dao = OutputEnrollmentDao(
        enrollmentId: result["id"].toString(),
        classId: result["class_id"].toString(),
        traineeId: result["trainee_id"].toString(),
        finalGrade: result["final_grade"] is num
            ? (result["final_grade"] as num).toDouble()
            : double.parse(result["final_grade"].toString()),
      );

      return Result.success(dao);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputEnrollmentDao>> create(CreateEnrollmentDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      await db.insert(
        table: table,
        insertData: {
          "class_id": dto.classId,
          "trainee_id": dto.traineeId,
          "final_grade": dto.finalGrade,
        },
      );

      // Retrieval: class_id + trainee_id should be unique?
      final created = await db.getOne(
        table: table,
        where: {"class_id": dto.classId, "trainee_id": dto.traineeId},
      );

      if (created.isEmpty) {
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created Enrollment could not be retrieved",
          ),
        );
      }

      return Result.success(
        OutputEnrollmentDao(
          enrollmentId: created["id"].toString(),
          classId: created["class_id"].toString(),
          traineeId: created["trainee_id"].toString(),
          finalGrade: created["final_grade"] is num
              ? (created["final_grade"] as num).toDouble()
              : double.parse(created["final_grade"].toString()),
        ),
      );
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputEnrollmentDao>> update(
    String id,
    UpdateEnrollmentDto dto,
  ) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final updateData = <String, dynamic>{};
      if (dto.classId != null) updateData["class_id"] = dto.classId;
      if (dto.traineeId != null) updateData["trainee_id"] = dto.traineeId;
      if (dto.finalGrade != null) updateData["final_grade"] = dto.finalGrade;

      if (updateData.isEmpty) {
        return getById(id);
      }

      await db.update(table: table, updateData: updateData, where: {"id": id});

      return getById(id);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputEnrollmentDao>> delete(String id) async {
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
