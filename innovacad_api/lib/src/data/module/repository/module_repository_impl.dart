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

      final modules = results.map((data) {
        return OutputModuleDao.fromJson(data);
      }).toList();

      return Result.success(modules);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the modules...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputModuleDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final result =
          await db.getOne(table: table, where: {"module_id": id})
              as Map<String, dynamic>;

      if (result.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.notFound,
            "Something went wrong while fetching the module",
          ),
        );

      return Result.success(OutputModuleDao.fromJson(result));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputModuleDao>> create(CreateModuleDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      await db.startTrans();

      await db.insert(
        table: table,
        insertData: {
          "name": dto.name,
          "duration": dto.duration,
          "has_computers": dto.hasComputers,
          "has_projector": dto.hasProjector,
          "has_whiteboard": dto.hasWhiteboard,
          "has_smartboard": dto.hasSmartboard,
        },
      );

      final created = await db.getOne(table: table, where: {"name": dto.name});

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created module could not be retrieved",
          ),
        );

      await db.commit();

      return Result.success(
        OutputModuleDao.fromJson(
          created
              .map((k, v) => MapEntry(k.toString(), v))
              .cast<String, dynamic>(),
        ),
      );
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputModuleDao>> update(String id, UpdateModuleDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final existingModule = await getById(id);

      if (existingModule.isFailure || existingModule.data == null)
        return existingModule;

      final updateData = <String, dynamic>{};

      if (dto.name != null && existingModule.data!.name != dto.name)
        updateData["name"] = dto.name;

      if (dto.duration != null && existingModule.data!.duration != dto.duration)
        updateData["duration"] = dto.duration;

      if (dto.hasComputers != null &&
          existingModule.data!.hasComputers != dto.hasComputers)
        updateData["has_computers"] = dto.hasComputers;

      if (dto.hasProjector != null &&
          existingModule.data!.hasProjector != dto.hasProjector)
        updateData["has_projector"] = dto.hasProjector;

      if (dto.hasWhiteboard != null &&
          existingModule.data!.hasWhiteboard != dto.hasWhiteboard)
        updateData["has_whiteboard"] = dto.hasWhiteboard;

      if (dto.hasSmartboard != null &&
          existingModule.data!.hasSmartboard != dto.hasSmartboard)
        updateData["has_smartboard"] = dto.hasSmartboard;

      if (updateData.isEmpty) return existingModule;

      await db.update(
        table: table,
        updateData: updateData,
        where: {"module_id": id},
      );

      return await getById(id);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputModuleDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingModule = await getById(id);

      if (existingModule.isFailure || existingModule.data == null)
        return existingModule;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"module_id": id});

      return existingModule;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the module...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }
}
