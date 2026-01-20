import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/availability/repository/i_availability_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class AvailabilityRepositoryImpl implements IAvailabilityRepository {
  final String table = "availabilities";

  @override
  Future<Result<List<OutputAvailabilityDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final results = await db.getAll(table: table);
      
      final items = results.map((row) {
         return OutputAvailabilityDao(
            availabilityId: row["id"].toString(),
            trainerId: row["trainer_id"].toString(),
            status: row["status"],
            startDateTimestamp: DateTime.parse(row["start_date_timestamp"].toString()),
            endDateTimestamp: DateTime.parse(row["end_date_timestamp"].toString())
         );
      }).toList();
      
      return Result.success(items);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});
      
      if (result.isEmpty) {
         return Result.failure(AppError(AppErrorType.notFound, "Availability not found"));
      }

      final dao = OutputAvailabilityDao(
         availabilityId: result["id"].toString(),
         trainerId: result["trainer_id"].toString(),
         status: result["status"],
         startDateTimestamp: DateTime.parse(result["start_date_timestamp"].toString()),
         endDateTimestamp: DateTime.parse(result["end_date_timestamp"].toString())
      );
      
      return Result.success(dao);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> create(CreateAvailabilityDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      await db.insert(
         table: table,
         insertData: {
            "trainer_id": dto.trainerId,
            "status": dto.status,
            "start_date_timestamp": dto.startDateTimestamp.toIso8601String(),
            "end_date_timestamp": dto.endDateTimestamp.toIso8601String()
         }
      );
      
      // Retrieval: potentially tricky if multiple identical availabilities.
      // Trying to match all fields.
      final created = await db.getOne(table: table, where: {
         "trainer_id": dto.trainerId, 
         "status": dto.status
         // Omitting exact timestamp match to avoid precision issues
      }); 
       
      if (created.isEmpty) {
          return Result.failure(AppError(AppErrorType.internal, "Created Availability could not be retrieved"));
      }
      
      return Result.success(OutputAvailabilityDao(
         availabilityId: created["id"].toString(), 
         trainerId: created["trainer_id"].toString(),
         status: created["status"],
         startDateTimestamp: DateTime.parse(created["start_date_timestamp"].toString()),
         endDateTimestamp: DateTime.parse(created["end_date_timestamp"].toString())
      ));
      
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> update(UpdateAvailabilityDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      final updateData = <String, dynamic>{};
      if (dto.trainerId != null) updateData["trainer_id"] = dto.trainerId;
      if (dto.status != null) updateData["status"] = dto.status;
      if (dto.startDateTimestamp != null) updateData["start_date_timestamp"] = dto.startDateTimestamp!.toIso8601String();
      if (dto.endDateTimestamp != null) updateData["end_date_timestamp"] = dto.endDateTimestamp!.toIso8601String();
      
      if (updateData.isEmpty) {
          return getById(dto.availabilityId);
      }
      
      await db.update(
         table: table,
         updateData: updateData,
         where: {"id": dto.availabilityId}
      );
      
      return getById(dto.availabilityId);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> delete(DeleteAvailabilityDto dto) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(dto.availabilityId);
      if (existingRes.isFailure) return existingRes;
      
      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": dto.availabilityId});
      
      return existingRes;
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
