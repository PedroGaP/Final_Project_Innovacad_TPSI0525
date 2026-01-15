import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/class_module/repository/i_class_module_repository.dart';
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
      
      final items = results.map((row) {
         return OutputClassModuleDao(
            classesModulesId: row["id"].toString(),
            classId: row["class_id"].toString(),
            coursesModulesId: row["courses_modules_id"].toString(),
            currentDuration: row["current_duration"] is int ? row["current_duration"] : int.parse(row["current_duration"].toString())
         );
      }).toList();
      
      await db.close();
      return Result.success(items);
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});
      
      if (result.isEmpty) {
         await db.close();
         return Result.failure(AppError(AppErrorType.notFound, "ClassModule not found"));
      }

      final dao = OutputClassModuleDao(
         classesModulesId: result["id"].toString(),
         classId: result["class_id"].toString(),
         coursesModulesId: result["courses_modules_id"].toString(),
         currentDuration: result["current_duration"] is int ? result["current_duration"] : int.parse(result["current_duration"].toString())
      );
      
      await db.close();
      return Result.success(dao);
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
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
            "current_duration": dto.currentDuration
         }
      );
      
      // Retrieval strategy: by unique combo? class_id + courses_modules_id should ideally be unique? 
      // If not, we might have issues.
      final created = await db.getOne(table: table, where: {
         "class_id": dto.classId, 
         "courses_modules_id": dto.coursesModulesId
      }); 
       
      if (created.isEmpty) {
          await db.close();
          return Result.failure(AppError(AppErrorType.internal, "Created ClassModule could not be retrieved"));
      }
      
      await db.close();
      return Result.success(OutputClassModuleDao(
         classesModulesId: created["id"].toString(), 
         classId: created["class_id"].toString(), 
         coursesModulesId: created["courses_modules_id"].toString(),
         currentDuration: created["current_duration"] is int ? created["current_duration"] : int.parse(created["current_duration"].toString())
      ));
      
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> update(UpdateClassModuleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      final updateData = <String, dynamic>{};
      if (dto.classId != null) updateData["class_id"] = dto.classId;
      if (dto.coursesModulesId != null) updateData["courses_modules_id"] = dto.coursesModulesId;
      if (dto.currentDuration != null) updateData["current_duration"] = dto.currentDuration;
      
      if (updateData.isEmpty) {
          await db.close();
          return getById(dto.classesModulesId);
      }
      
      await db.update(
         table: table,
         updateData: updateData,
         where: {"id": dto.classesModulesId}
      );
      
      await db.close();
      return getById(dto.classesModulesId);
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputClassModuleDao>> delete(DeleteClassModuleDto dto) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(dto.classesModulesId);
      if (existingRes.isFailure) return existingRes;
      
      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": dto.classesModulesId});
      await db.close();
      
      return existingRes;
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
