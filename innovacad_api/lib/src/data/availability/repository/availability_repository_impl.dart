import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
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
          return OutputAvailabilityDao.fromJson(data);
        }).toList();

        return Result.success(items);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the availabilities...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> getById(String id) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final result =
            await db.getOne(table: table, where: {"availability_id": id})
                as Map<String, dynamic>;

        if (result.isEmpty)
          return Result.failure(
            AppError(AppErrorType.notFound, "Availability not found"),
          );

        return Result.success(OutputAvailabilityDao.fromJson(result));
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the availability...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> create(
    CreateAvailabilityDto dto,
  ) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.getConnection();

      await db.startTrans();

      final dateDay = dto.dateDay.toIso8601String();

      print(dto.toJson());

      await db.insert(
        table: table,
        insertData: {
          "trainer_id": dto.trainerId,
          "date_day": dateDay,
          "slot_number": dto.slotNumber,
          "is_booked": dto.isBooked,
        },
      );

      final created = await db.getOne(
        table: table,
        where: {
          "trainer_id": dto.trainerId,
          "date_day": dateDay,
          "slot_number": dto.slotNumber,
          "is_booked": dto.isBooked,
        },
      );

      if (created.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Created Availability could not be retrieved",
          ),
        );

      await db.commit();

      return Result.success(
        OutputAvailabilityDao.fromJson(
          created
              .map((k, v) => MapEntry(k.toString(), v))
              .cast<String, dynamic>(),
        ),
      );
    } catch (e, s) {
      if (db != null) await db.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while creating the availability...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> update(
    String id,
    UpdateAvailabilityDto dto,
  ) async {
    MysqlUtils? db;

    try {
      final existingAvailability = await getById(id);

      if (existingAvailability.isFailure || existingAvailability.data == null)
        return existingAvailability;

      db = await MysqlConfiguration.getConnection();

      final updateData = <String, dynamic>{};

      if (dto.trainerId != null &&
          dto.trainerId != existingAvailability.data!.trainerId)
        updateData["trainer_id"] = dto.trainerId;

      if (dto.dateDay != null &&
          dto.dateDay != existingAvailability.data!.dateDay)
        updateData["date_day"] = dto.dateDay!.toIso8601String();

      if (dto.slotNumber != null &&
          dto.slotNumber != existingAvailability.data!.slotNumber)
        updateData["slot_number"] = dto.slotNumber;

      if (dto.isBooked != null &&
          dto.isBooked != existingAvailability.data!.isBooked)
        updateData["is_booked"] = dto.isBooked;

      if (updateData.isEmpty) return existingAvailability;

      await db.update(
        table: table,
        updateData: updateData,
        where: {"availability_id": id},
      );

      return await getById(id);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the availability...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputAvailabilityDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingAvailability = await getById(id);

      if (existingAvailability.isFailure || existingAvailability.data == null)
        return existingAvailability;

      db = await MysqlConfiguration.getConnection();

      await db.delete(table: table, where: {"availability_id": id});

      return existingAvailability;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the availability...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<List<SlotsOutputDao>>> getAllSlots() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final results = await db.getAll(table: "ref_slots");

        final items = results.map((data) {
          return SlotsOutputDao.fromJson(data);
        }).toList();

        return Result.success(items);
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the slots...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }
}
