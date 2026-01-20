import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:innovacad_api/src/domain/trainer/repository/i_trainer_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart' as v;

@v.Repository()
class TrainerRepositoryImpl implements ITrainerRepository {
  final RemoteUserService _remoteUserService;

  final String table = "trainers";

  TrainerRepositoryImpl(this._remoteUserService);

  @override
  Future<Result<List<OutputTrainerDao>>> getAll() async {
    MysqlUtils? db;

    final List<OutputTrainerDao> daos = [];
    try {
      db = await MysqlConfiguration.connect();

      final query =
          "SELECT t.trainer_id, t.user_id, t.birthday_date, t.specialization, u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt, u.emailVerified FROM `trainers` t JOIN `user` u ON t.user_id = u.id";
      final results = await db.query(query);

      for (var row in results.rows) {
        daos.add(OutputTrainerDao.fromJson(row));
      }

      return Result.success(daos);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTrainerDao>> getById(String trainerId) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final results = await db.query(
        "SELECT t.trainer_id, t.user_id, t.birthday_date, t.specialization, u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt, u.emailVerified "
        "FROM `trainers` t JOIN `user` u ON t.user_id = u.id WHERE t.trainer_id = ? LIMIT 1",
        whereValues: [trainerId],
        isStmt: true,
      );

      if (results.rows.length == 0) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Trainer not found"),
        );
      }

      return Result.success(OutputTrainerDao.fromJson(results.rows[0]));
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTrainerDao>> create(CreateTrainerDto dto) async {
    MysqlUtils? db;
    String? createdUserId;

    try {
      final result = await this.getAll();

      if (result.isFailure)
        return Result.failure(
          AppError(AppErrorType.internal, "Failed to fetch trainers."),
        );

      for (var trainer in result.data!) {
        if (trainer.email == dto.email || trainer.username == dto.username)
          return Result.failure(
            AppError(
              AppErrorType.internal,
              "A trainer with the username or email provided already exists.",
            ),
          );
      }

      final responseUser = await _remoteUserService.signUpUser(
        dto.email,
        dto.name,
        dto.password,
      );

      if (responseUser.isFailure)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Failed to singup the trainer user.",
            details: {"error": responseUser.error},
          ),
        );

      final role = "trainer";

      final userData = responseUser.data as Map<String, dynamic>;
      userData["username"] = dto.username;
      userData["role"] = role;
      createdUserId = userData["id"];

      db = await MysqlConfiguration.connect();

      final updateCount = await db.update(
        table: "user",
        updateData: {"username": dto.username, "role": role},
        where: {"id": createdUserId},
      );

      if (updateCount < BigInt.from(0))
        throw "Something went wrong while updating the role or username for tainer user.";

      await db.insert(
        table: table,
        insertData: {
          "user_id": createdUserId,
          "birthday_date": dto.birthdayDate,
          "specialization": dto.specialization,
        },
      );

      final updatedResult = await getAll();

      if (updatedResult.isFailure) throw "Failed to fetch trainers.";

      var trainerExists = false;

      for (var trainer in updatedResult.data!) {
        if (trainer.id == createdUserId) {
          trainerExists = true;
          userData["trainer_id"] = trainer.trainerId;
          userData["user_id"] = trainer.id;
          userData["birthday_date"] = trainer.birthdayDate;
          userData["specialization"] = trainer.specialization;
          break;
        }
      }

      if (trainerExists == false) throw "Failed to create the trainer.";

      final dao = OutputTrainerDao.fromJson(userData);

      return Result.success(dao);
    } catch (e) {
      _remoteUserService.deleteUserAsAdmin(createdUserId!);

      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTrainerDao>> update(
    String trainerId,
    UpdateTrainerDto dto,
  ) async {
    MysqlUtils? db;
    try {
      final res = await getById(trainerId);

      if (res.isFailure)
        return Result.failure(
          AppError(
            AppErrorType.notFound,
            "Couldn't find the trainer with provided trainer id",
            details: {...(res.error?.details ?? {})},
          ),
        );

      final isUserUpdated = await _remoteUserService.updateUser(res.data!.id, dto);

      if (isUserUpdated.isFailure)
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "Failed to update trainer user data",
            details: {"error": isUserUpdated.error},
          ),
        );

      db = await MysqlConfiguration.connect();
      await db.startTrans();

      final trainerData = <String, dynamic>{};
      if (dto.specialization != null)
        trainerData["specialization"] = dto.specialization;
      if (dto.birthdayDate != null)
        trainerData["birthday_date"] = dto.birthdayDate;

      if (trainerData.isNotEmpty) {
        await db.update(
          table: table,
          updateData: trainerData,
          where: {"trainer_id": trainerId},
        );
      }

      await db.commit();

      return await getById(trainerId);
    } catch (e, s) {
      if (db != null) {
        try {
          await db.rollback();
        } catch (_) {}
      }
      print("[ERROR] Update Trainer: $e\n$s");
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTrainerDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingRes = await getById(id);
      if (existingRes.isFailure) return existingRes;

      final existing = existingRes.data!;
      final deleteAuthRes = await _remoteUserService.deleteUserAsAdmin(
        existing.id,
      );

      if (deleteAuthRes.isFailure) return Result.failure(deleteAuthRes.error!);

      db = await MysqlConfiguration.connect();

      await db.startTrans();

      await db.delete(table: table, where: {"trainer_id": id});
      await db.delete(table: "user", where: {"id": existing.id});

      await db.commit();

      return existingRes;
    } catch (e) {
      if (db != null) await db.rollback();

      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
