import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/class_model/repository/i_class_repository.dart';
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
      
      final classes = results.map((row) {
         // Enum conversion: DB string -> Enum
         final statusStr = row["status"];
         final status = ClassStatusEnum.values.firstWhere(
            (e) => e.toString().split('.').last == statusStr,
            orElse: () => ClassStatusEnum.starting // Default or error?
         );
         
         final start = DateTime.parse(row["start_date_timestamp"].toString());
         final end = DateTime.parse(row["end_date_timestamp"].toString());

         return OutputClassDao(
            classId: row["id"].toString(),
            courseId: row["course_id"].toString(),
            location: row["location"],
            identifier: row["identifier"],
            status: status,
            startDateTimestamp: start,
            endDateTimestamp: end
         );
      }).toList();
      
      return Result.success(classes);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputClassDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});
      
      if (result.isEmpty) {
         return Result.failure(AppError(AppErrorType.notFound, "Class not found"));
      }
      
      final statusStr = result["status"];
      final status = ClassStatusEnum.values.firstWhere(
         (e) => e.toString().split('.').last == statusStr,
         orElse: () => ClassStatusEnum.starting
      );
      
      final start = DateTime.parse(result["start_date_timestamp"].toString());
      final end = DateTime.parse(result["end_date_timestamp"].toString());

      final dao = OutputClassDao(
         classId: result["id"].toString(),
         courseId: result["course_id"].toString(),
         location: result["location"],
         identifier: result["identifier"],
         status: status,
         startDateTimestamp: start,
         endDateTimestamp: end
      );
      
      return Result.success(dao);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputClassDao>> create(CreateClassDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      await db.insert(
         table: table,
         insertData: {
            "course_id": dto.courseId,
            "location": dto.location,
            "identifier": dto.identifier,
            "status": dto.status.toString().split('.').last, // Store as string
            "start_date_timestamp": dto.startDateTimestamp.toIso8601String(),
            "end_date_timestamp": dto.endDateTimestamp.toIso8601String()
         }
      );
      
      // Retrieval: identifier likely unique? 
      final created = await db.getOne(table: table, where: {"identifier": dto.identifier}); 
       
      if (created.isEmpty) {
          return Result.failure(AppError(AppErrorType.internal, "Created class could not be retrieved"));
      }
      
      // Reuse logic or construct directly
      final statusStr = created["status"];
      final status = ClassStatusEnum.values.firstWhere(
         (e) => e.toString().split('.').last == statusStr,
         orElse: () => ClassStatusEnum.starting
      );
      
      return Result.success(OutputClassDao(
         classId: created["id"].toString(), 
         courseId: created["course_id"].toString(),
         location: created["location"],
         identifier: created["identifier"],
         status: status,
         startDateTimestamp: DateTime.parse(created["start_date_timestamp"].toString()),
         endDateTimestamp: DateTime.parse(created["end_date_timestamp"].toString())
      ));
      
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputClassDao>> update(UpdateClassDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      final updateData = <String, dynamic>{};
      if (dto.courseId != null) updateData["course_id"] = dto.courseId;
      if (dto.location != null) updateData["location"] = dto.location;
      if (dto.identifier != null) updateData["identifier"] = dto.identifier;
      if (dto.status != null) updateData["status"] = dto.status.toString().split('.').last;
      if (dto.startDateTimestamp != null) updateData["start_date_timestamp"] = dto.startDateTimestamp!.toIso8601String();
      if (dto.endDateTimestamp != null) updateData["end_date_timestamp"] = dto.endDateTimestamp!.toIso8601String();
      
      if (updateData.isEmpty) {
          return getById(dto.classId);
      }
      
      await db.update(
         table: table,
         updateData: updateData,
         where: {"id": dto.classId}
      );
      
      return getById(dto.classId);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputClassDao>> delete(DeleteClassDto dto) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(dto.classId);
      if (existingRes.isFailure) return existingRes;
      
      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": dto.classId});
      
      return existingRes;
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
