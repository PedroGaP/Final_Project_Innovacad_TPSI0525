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
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final results = await db.getAll(table: table);
      
      final items = results.map((row) {
         return OutputGradeDao(
            gradeId: row["id"].toString(),
            classModuleId: row["class_module_id"].toString(),
            traineeId: row["trainee_id"].toString(),
            grade: row["grade"] is num ? (row["grade"] as num).toDouble() : double.parse(row["grade"].toString()),
            gradeType: row["grade_type"],
            createdAt: DateTime.parse(row["created_at"].toString()),
            updatedAt: DateTime.parse(row["updated_at"].toString())
         );
      }).toList();
      
      return Result.success(items);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputGradeDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});
      
      if (result.isEmpty) {
         return Result.failure(AppError(AppErrorType.notFound, "Grade not found"));
      }

      final dao = OutputGradeDao(
         gradeId: result["id"].toString(),
         classModuleId: result["class_module_id"].toString(),
         traineeId: result["trainee_id"].toString(),
         grade: result["grade"] is num ? (result["grade"] as num).toDouble() : double.parse(result["grade"].toString()),
         gradeType: result["grade_type"],
         createdAt: DateTime.parse(result["created_at"].toString()),
         updatedAt: DateTime.parse(result["updated_at"].toString())
      );
      
      return Result.success(dao);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      // Auto-set timestamps? Or assume DB defaults?
      // Old entity had created_at and updated_at. I'll set them here or rely on DB defaults if they exist.
      // Usually better to let DB handle created_at, but we need to return full object.
      // I'll set them for safety if DB allows, or rely on fetching.
      
      await db.insert(
         table: table,
         insertData: {
            "class_module_id": dto.classModuleId,
            "trainee_id": dto.traineeId,
            "grade": dto.grade,
            "grade_type": dto.gradeType,
            "created_at": DateTime.now().toIso8601String(), // Providing timestamp
            "updated_at": DateTime.now().toIso8601String()
         }
      );
      
      // Retrieval: class_module_id + trainee_id + grade_type?
      final created = await db.getOne(table: table, where: {
         "class_module_id": dto.classModuleId, 
         "trainee_id": dto.traineeId,
         "grade_type": dto.gradeType
      }); 
       
      if (created.isEmpty) {
          return Result.failure(AppError(AppErrorType.internal, "Created Grade could not be retrieved"));
      }
      
      return Result.success(OutputGradeDao(
         gradeId: created["id"].toString(), 
         classModuleId: created["class_module_id"].toString(),
         traineeId: created["trainee_id"].toString(),
         grade: created["grade"] is num ? (created["grade"] as num).toDouble() : double.parse(created["grade"].toString()),
         gradeType: created["grade_type"],
         createdAt: DateTime.parse(created["created_at"].toString()),
         updatedAt: DateTime.parse(created["updated_at"].toString())
      ));
      
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputGradeDao>> update(UpdateGradeDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      final updateData = <String, dynamic>{};
      if (dto.classModuleId != null) updateData["class_module_id"] = dto.classModuleId;
      if (dto.traineeId != null) updateData["trainee_id"] = dto.traineeId;
      if (dto.grade != null) updateData["grade"] = dto.grade;
      if (dto.gradeType != null) updateData["grade_type"] = dto.gradeType;
      
      // update timestamp
      updateData["updated_at"] = DateTime.now().toIso8601String();
      
      if (updateData.length <= 1) { // Only updated_at
          // If only timestamp updated (no meaningful changes), just return existing.
          return getById(dto.gradeId);
      }
      
      await db.update(
         table: table,
         updateData: updateData,
         where: {"id": dto.gradeId}
      );
      
      return getById(dto.gradeId);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputGradeDao>> delete(DeleteGradeDto dto) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(dto.gradeId);
      if (existingRes.isFailure) return existingRes;
      
      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": dto.gradeId});
      
      return existingRes;
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
