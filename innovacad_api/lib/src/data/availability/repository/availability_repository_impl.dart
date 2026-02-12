import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/core/extensions/mysql_utils_extension.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Repository()
class AvailabilityRepositoryImpl implements IAvailabilityRepository {
  final String table = "availabilities";

  @override
  Future<Result<List<OutputAvailabilityDao>>> getAll() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.getAll(table: table);

        final items = results.map((data) {
          return OutputAvailabilityDao.fromJson(data.cast<String, dynamic>());
        }).toList();

        return Result.success(items);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching all availabilities",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> getById(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final result = await db.getOne(
          table: table,
          where: {"availability_id": id},
        );

        if (result.isEmpty) {
          return Result.failure(
            AppError(AppErrorType.notFound, "Availability not found"),
          );
        }

        return Result.success(
          OutputAvailabilityDao.fromJson(result.cast<String, dynamic>()),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching availability by id",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> create(
    CreateAvailabilityDto dto,
  ) async {
    try {
      if (dto.dateDay.weekday == DateTime.saturday ||
          dto.dateDay.weekday == DateTime.sunday) {
        return Result.failure(
          AppError(
            AppErrorType.badRequest,
            "Não é permitido criar disponibilidades aos fins de semana (Sábados ou Domingos).",
          ),
        );
      }

      final db = await MysqlConfiguration.getConnection();
      final availabilityId = const Uuid().v4();
      final dateDay = DateTime(
        dto.dateDay.year,
        dto.dateDay.month,
        dto.dateDay.day,
        0, 0, 0,
      ).toIso8601String();

      return await db.transaction((txn) async {
        await txn.insert(
          table: table,
          insertData: {
            "availability_id": availabilityId,
            "trainer_id": dto.trainerId,
            "date_day": dateDay,
            "slot_number": dto.slotNumber,
            "is_booked": dto.isBooked,
          },
        );

        final created = await txn.getOne(
          table: table,
          where: {"availability_id": availabilityId},
        );

        print("DEBUG: Created availability data: $created");
        
        if (created.isEmpty) {
          throw Exception("Failed to retrieve created availability");
        }

        return Result.success(
          OutputAvailabilityDao.fromJson(created.cast<String, dynamic>()),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to create availability",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> update(
    String id,
    UpdateAvailabilityDto dto,
  ) async {
    try {
      final db = await MysqlConfiguration.getConnection();

      return await db.transaction((txn) async {
        final existing = await txn.getOne(
          table: table,
          where: {"availability_id": id},
        );
        if (existing.isEmpty) {
          return Result.failure(AppError(AppErrorType.notFound, "Not found"));
        }

        final updateData = <String, dynamic>{};
        if (dto.trainerId != null) updateData["trainer_id"] = dto.trainerId;
        if (dto.dateDay != null) {
          final dateDay = DateTime(
            dto.dateDay!.year,
            dto.dateDay!.month,
            dto.dateDay!.day,
            0, 0, 0,
          ).toIso8601String();
          updateData["date_day"] = dateDay;
        }
        if (dto.slotNumber != null) updateData["slot_number"] = dto.slotNumber;
        if (dto.isBooked != null)
          updateData["is_booked"] = dto.isBooked;

        if (updateData.isEmpty) {
          return Result.success(
            OutputAvailabilityDao.fromJson(existing.cast<String, dynamic>()),
          );
        }

        await txn.update(
          table: table,
          updateData: updateData,
          where: {"availability_id": id},
        );

        final updated = await txn.getOne(
          table: table,
          where: {"availability_id": id},
        );
        return Result.success(
          OutputAvailabilityDao.fromJson(updated.cast<String, dynamic>()),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to update availability",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> delete(String id) async {
    try {
      final db = await MysqlConfiguration.getConnection();

      return await db.transaction((txn) async {
        final existing = await txn.getOne(
          table: table,
          where: {"availability_id": id},
        );
        if (existing.isEmpty) {
          return Result.failure(AppError(AppErrorType.notFound, "Not found"));
        }

        await txn.delete(table: table, where: {"availability_id": id});

        return Result.success(
          OutputAvailabilityDao.fromJson(existing.cast<String, dynamic>()),
        );
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to delete availability",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<SlotsOutputDao>>> getAllSlots() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.getAll(table: "ref_slots");

        final items = results.map((data) {
          return SlotsOutputDao.fromJson(data.cast<String, dynamic>());
        }).toList();

        return Result.success(items);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching ref_slots",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }
}
