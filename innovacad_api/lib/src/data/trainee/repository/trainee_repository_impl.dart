import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/trainee/repository/i_trainee_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class TraineeRepositoryImpl implements ITraineeRepository {
  final RemoteUserService _remoteUserService;
  final String table = "trainees";
  final String userTable = "user";

  TraineeRepositoryImpl(this._remoteUserService);

  @override
  Future<Result<List<OutputTraineeDao>>> getAll() async {
    MysqlUtils? db;

    final List<OutputTraineeDao> daos = [];
    try {
      db = await MysqlConfiguration.connect();

      final query =
          "SELECT t.trainee_id, t.user_id, t.birthday_date, u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt FROM `trainees` t JOIN `user` u ON t.user_id = u.id";
      final results = await db.query(query);

      for (var row in results.rows) {
        daos.add(OutputTraineeDao.fromJson(row));
      }

      return Result.success(daos);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTraineeDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final results = await db.query(
        "SELECT t.trainee_id, t.user_id, t.birthday_date, u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt "
        "FROM `trainees` t JOIN `user` u ON t.user_id = u.id WHERE t.trainee_id = ? LIMIT 1",
        whereValues: [id],
        isStmt: true,
      );

      if (results.rows.length == 0) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Trainee not found"),
        );
      }

      await db.close();
      return Result.success(OutputTraineeDao.fromJson(results.rows[0]));
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTraineeDao>> create(CreateTraineeDto dto) async {
    MysqlUtils? db;
    String? createdUserId;

    try {
      final result = await getAll();

      if (result.isFailure)
        return Result.failure(
          AppError(AppErrorType.internal, "Failed to fetch trainees."),
        );

      for (var trainee in result.data!) {
        if (trainee.email == dto.email || trainee.username == dto.username)
          return Result.failure(
            AppError(
              AppErrorType.internal,
              "A trainee with the username or email provided already exists.",
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
            "Failed to singup the trainee user.",
            details: {"error": responseUser.error},
          ),
        );

      final role = "trainee";

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
        throw "Something went wrong while updating the role or username for tainee user.";

      await db.insert(
        table: table,
        insertData: {
          "user_id": createdUserId,
          "birthday_date": dto.birthdayDate,
        },
      );

      final updatedResult = await getAll();

      if (updatedResult.isFailure) throw "Failed to fetch trainees.";

      var traineeExists = false;

      for (var trainee in updatedResult.data!) {
        if (trainee.id == createdUserId) {
          traineeExists = true;
          userData["trainee_id"] = trainee.traineeId;
          userData["user_id"] = trainee.id;
          userData["birthday_date"] = trainee.birthdayDate;
          break;
        }
      }

      if (traineeExists == false) throw "Failed to create the trainee.";

      final dao = OutputTraineeDao.fromJson(userData);

      return Result.success(dao);
    } catch (e) {
      _remoteUserService.deleteUserAsAdmin(createdUserId!);

      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTraineeDao>> update(
    String id,
    UpdateTraineeDto dto,
  ) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(id);
      if (existingRes.isFailure) return existingRes;
      final existing = existingRes.data!;

      db = await MysqlConfiguration.connect();
      await db.startTrans();

      // Update User fields
      final userUpdates = <String, dynamic>{};
      if (dto.name != null) userUpdates["name"] = dto.name;
      if (dto.username != null) userUpdates["username"] = dto.username;

      if (userUpdates.isNotEmpty) {
        await db.update(
          table: userTable,
          updateData: userUpdates,
          where: {"id": existing.id},
        );
      }

      // Update Trainee fields
      final traineeUpdates = <String, dynamic>{};
      if (dto.birthdayDate != null)
        traineeUpdates["birthday_date"] = dto.birthdayDate!.toIso8601String();

      if (traineeUpdates.isNotEmpty) {
        await db.update(
          table: table,
          updateData: traineeUpdates,
          where: {"trainee_id": id},
        );
      }

      await db.commit();
      await db.close();
      return getById(id);
    } catch (e) {
      if (db != null) {
        await db.rollback();
        await db.close();
      }
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTraineeDao>> delete(String id) async {
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

      await db.delete(table: table, where: {"trainee_id": id});
      await db.delete(table: userTable, where: {"id": existing.id});

      await db.commit();

      return existingRes;
    } catch (e) {
      if (db != null) await db.rollback();

      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
