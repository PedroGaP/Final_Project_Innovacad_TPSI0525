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

      final items = results.map((data) {
        return OutputEnrollmentDao.fromJson(data);
      }).toList();

      return Result.success(items);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the enrollments...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputEnrollmentDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final result =
          await db.getOne(table: table, where: {"enrollment_id": id})
              as Map<String, dynamic>;

      if (result.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "Enrollment not found"),
        );

      return Result.success(OutputEnrollmentDao.fromJson(result));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the enrollment...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputEnrollmentDao>> create(CreateEnrollmentDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      await db.startTrans();

      await db.insert(
        table: table,
        insertData: {
          "class_id": dto.classId,
          "trainee_id": dto.traineeId,
          "final_grade": dto.finalGradeDouble,
        },
      );

      final created =
          await db.getOne(
                table: table,
                where: {"class_id": dto.classId, "trainee_id": dto.traineeId},
              )
              as Map<String, dynamic>;

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created Enrollment could not be retrieved",
          ),
        );

      await db.commit();

      return Result.success(OutputEnrollmentDao.fromJson(created));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the enrollment...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
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

      final existingEnrollment = await getById(id);

      if (existingEnrollment.isFailure || existingEnrollment.data == null)
        return existingEnrollment;

      final updateData = <String, dynamic>{};

      if (dto.classId != null &&
          dto.classId != existingEnrollment.data!.classId)
        updateData["class_id"] = dto.classId;

      if ((dto.traineeId != null && dto.traineeId!.isNotEmpty) &&
          dto.traineeId != existingEnrollment.data!.traineeId) {
        updateData["trainee_id"] = dto.traineeId;
      }

      if (dto.finalGrade != null ||
          dto.finalGrade != existingEnrollment.data!.finalGrade)
        updateData["final_grade"] = dto.finalGradeDouble;

      if (updateData.isEmpty) return existingEnrollment;

      print("Update Data: $updateData");

      await db.update(
        table: table,
        updateData: updateData,
        where: {"enrollment_id": id},
        debug: true,
      );

      return await getById(id);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the enrollment...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputEnrollmentDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingEnrollment = await getById(id);

      if (existingEnrollment.isFailure || existingEnrollment.data == null)
        return existingEnrollment;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"enrollment_id": id});

      return existingEnrollment;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the enrollment...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }
}
