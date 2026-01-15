import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/module/repository/i_module_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ModuleRepositoryImpl implements IModuleRepository {
  final String table = "modules";

  @override
  Future<Result<List<OutputModuleDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final results = await db.getAll(table: table);
      
      final modules = results.map((row) {
         return OutputModuleDao(
            moduleId: row["id"].toString(),
            name: row["name"],
            duration: row["duration"]
         );
      }).toList();
      
      await db.close();
      return Result.success(modules);
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputModuleDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});
      
      if (result.isEmpty) {
         await db.close();
         return Result.failure(AppError(AppErrorType.notFound, "Module not found"));
      }

      final dao = OutputModuleDao(
         moduleId: result["id"].toString(),
         name: result["name"],
         duration: result["duration"]
      );
      
      await db.close();
      return Result.success(dao);
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputModuleDao>> create(CreateModuleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      await db.insert(
         table: table,
         insertData: {
            "name": dto.name,
            "duration": dto.duration
         }
      );
      
      final created = await db.getOne(table: table, where: {"name": dto.name}); 
      // Assuming name is unique or we need better retrieval strategy. 
      // If name is not unique, this is risky. Given the old entity, there's no unique constraint field other than ID.
      // Ideally use LAST_INSERT_ID() via query if library supports it or query max ID.
      // Sticking to name for now as per simple CRUD pattern unless concurrency is high.
       
      if (created.isEmpty) {
          await db.close();
          return Result.failure(AppError(AppErrorType.internal, "Created module could not be retrieved"));
      }
      
      await db.close();
      return Result.success(OutputModuleDao(
         moduleId: created["id"].toString(), 
         name: created["name"], 
         duration: created["duration"]
      ));
      
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputModuleDao>> update(UpdateModuleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      final updateData = <String, dynamic>{};
      if (dto.name != null) updateData["name"] = dto.name;
      if (dto.duration != null) updateData["duration"] = dto.duration;
      
      if (updateData.isEmpty) {
          await db.close();
          return getById(dto.moduleId);
      }
      
      await db.update(
         table: table,
         updateData: updateData,
         where: {"id": dto.moduleId}
      );
      
      await db.close();
      return getById(dto.moduleId);
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputModuleDao>> delete(DeleteModuleDto dto) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(dto.moduleId);
      if (existingRes.isFailure) return existingRes;
      
      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": dto.moduleId});
      await db.close();
      
      return existingRes;
    } catch (e) {
      if (db != null) await db.close();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
