import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/grade/repository/i_grade_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class GradeRepositoryImpl implements IGradeRepository {
  final String table = "grades";

  @override
  Future<Result<List<OutputGradeDao>>> getAll() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.getAll(table: table);

        final grades = results.map((data) {
          return OutputGradeDao.fromJson(data);
        }).toList();

        return Result.success(grades);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Some went wrong while fetching the grades...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputGradeDao>> getById(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final result =
            await db.getOne(table: table, where: {"grade_id": id})
                as Map<String, dynamic>;

        if (result.isEmpty)
          return Result.failure(
            AppError(AppErrorType.notFound, "Grade not found"),
          );

        return Result.success(OutputGradeDao.fromJson(result));
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the grade...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.getConnection();

      await db.startTrans();

      await db.insert(
        table: table,
        insertData: {
          "class_module_id": dto.classModuleId,
          "trainee_id": dto.traineeId,
          "grade": dto.grade,
          "grade_type": dto.gradeType,
        },
      );

      final created =
          await db.getOne(
                table: table,
                where: {
                  "class_module_id": dto.classModuleId,
                  "trainee_id": dto.traineeId,
                  "grade_type": dto.gradeType,
                },
              )
              as Map<String, dynamic>;

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created Grade could not be retrieved",
          ),
        );

      await db.commit();

      return Result.success(OutputGradeDao.fromJson(created));
    } catch (e, s) {
      if (db != null) await db.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating grade...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputGradeDao>> update(String id, UpdateGradeDto dto) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final existingGrade = await getById(id);

        if (existingGrade.isFailure || existingGrade.data == null)
          return existingGrade;

        final updateData = <String, dynamic>{};

        if (dto.classModuleId != null &&
            dto.classModuleId != existingGrade.data!.classModuleId)
          updateData["class_module_id"] = dto.classModuleId;

        if (dto.traineeId != null &&
            dto.traineeId != existingGrade.data!.traineeId)
          updateData["trainee_id"] = dto.traineeId;

        if (dto.grade != null && dto.grade != existingGrade.data!.grade)
          updateData["grade"] = dto.grade;

        if (dto.gradeType != null &&
            dto.gradeType != existingGrade.data!.gradeType)
          updateData["grade_type"] = dto.gradeType;

        if (updateData.isEmpty) return existingGrade;

        await db.update(
          table: table,
          updateData: updateData,
          where: {"grade_id": id},
        );

        return await getById(id);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the grade...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputGradeDao>> delete(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final existingGrade = await getById(id);

        if (existingGrade.isFailure || existingGrade.data == null)
          return existingGrade;

        await db.delete(table: table, where: {"grade_id": id});

        return existingGrade;
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the grade...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }
}
