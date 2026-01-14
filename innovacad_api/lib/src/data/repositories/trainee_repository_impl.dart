import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/api/utils/token_utils.dart';
import 'package:innovacad_api/src/api/utils/update_utils.dart';
import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/data/repositories/sign_repository_impl.dart';
import 'package:innovacad_api/src/domain/daos/trainee/trainee_user_dao.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_user_update_dto.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signin_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainee.dart';
import 'package:innovacad_api/src/domain/repositories/trainee_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart' as v;

@v.Repository()
class TraineeRepositoryImpl implements ITraineeRepository {
  final String table = "trainees";
  final String traineeUserTable = "trainees t,user u";
  final String traineeUserFields =
      "t.*, u.id, u.name, u.image, u.role, u.username, u.email, u.createdAt";
  final v.ApplicationSettings _settings;
  final Dio _dio;

  TraineeRepositoryImpl(this._settings, this._dio);

  @override
  Future<Result<List<TraineeUserDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      List<Map<String, dynamic>> tempTrainees = (await db.getAll(
        table: traineeUserTable,
        where: "u.id = t.user_id",
        fields: traineeUserFields,
      )).cast();

      print(tempTrainees);

      if (tempTrainees.isEmpty) {
        return Result.success<List<TraineeUserDao>>([]);
      }

      final trainees = tempTrainees
          .map((e) => TraineeUserDao.fromJson(e))
          .toList()
          .cast<TraineeUserDao>();

      return Result.success<List<TraineeUserDao>>(trainees);
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      print("ass");
      return Result.failure<List<TraineeUserDao>>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<TraineeUserDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      Map<String, dynamic> tempTrainee = (await db.getOne(
        table: traineeUserTable,
        where: {'trainee_id': id},
        fields: traineeUserFields,
      )).cast();

      print(tempTrainee);

      if (tempTrainee.isEmpty)
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.notFound, 'Trainee not found'),
        );

      final trainee = TraineeUserDao.fromJson(tempTrainee);
      return Result.success<TraineeUserDao>(trainee);
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return Result.failure<TraineeUserDao>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<TraineeUserDao>> create(TraineeCreateDto dto) async {
    MysqlUtils? db;

    String? createdUserId;

    try {
      // 1. Create the user in the auth api

      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/sign-up/email",
      );

      final response = await _dio.postUri(
        uri,
        data: {"email": dto.email, "name": dto.name, "password": dto.password},
      );

      if (response.statusCode != HttpStatus.ok)
        throw "Auth API failed with status ${response.statusCode}";

      // 2. Get the created user token

      final token = TokenUtils.getUserToken(response.headers["set-cookie"]![1]);
      if (token == null) throw "Failed to fetch the user token.";

      // 3. Add missing fields for the create user

      var rawTraineeMap = response.data["user"];
      var cleanedTraineeMap = {
        "id": rawTraineeMap["id"],
        "email": rawTraineeMap["email"] ?? dto.email,
        "username": rawTraineeMap["username"] ?? dto.username,
        "name": rawTraineeMap["name"] ?? dto.name,
        "trainee_id": null,
        "createdAt": rawTraineeMap["createdAt"],
        "birthday_date": dto.birthdayDate,
        "token": token,
        "role": null,
        "image": null,
      };

      createdUserId = cleanedTraineeMap["id"];

      db = await MysqlConfiguration.connect();

      // 3. Update the created user with the missing fields

      final role = "trainee";

      final updateCount = await db.update(
        table: "user",
        updateData: {"username": dto.username, "role": role},
        where: {"id": createdUserId},
      );

      cleanedTraineeMap["role"] = role;

      if (updateCount == BigInt.from(0))
        throw "Failed to update the missing fileds for the created user.";

      // 4. Start the transaction that will commit the trainee changes

      await db.startTrans();

      // 5. Create the trainee for the created user

      await db.insert(
        table: table,
        insertData: {
          "user_id": createdUserId,
          "birthday_date": cleanedTraineeMap["birthday_date"],
        },
      );

      // 6. Verify if the trainee was successfully created

      final dbRawTrainee =
          await db.getOne(table: table, where: {"user_id": createdUserId})
              as Map<String, dynamic>;
      cleanedTraineeMap["trainee_id"] = dbRawTrainee["trainee_id"];

      Trainee.fromJson(
        cleanedTraineeMap,
      ); // This throws an error if it fails its all good :)

      // 8. Commit the trainee changes

      await db.commit();

      // 9. Return the trainee dao

      return Result.success(TraineeUserDao.fromJson(cleanedTraineeMap));
    } catch (error, st) {
      try {
        if (db != null) {
          await db.rollback();
          await db.close();
        }

        // 1. Delete the user that was created

        final repository = SignRepositoryImpl(_settings, _dio);

        final user = await repository.signin(
          UserSigninDto(
            email: _settings["auth"]["admin_name"],
            password: _settings["auth"]["admin_password"],
          ),
        );

        final uriRemoveUser = Uri(
          scheme: _settings["auth"]["protocol"],
          host: _settings["auth"]["host"],
          port: _settings["auth"]["port"],
          path: "/api/auth/admin/remove-user",
        );

        String? token = user.data!.token;

        final response = await _dio.postUri(
          uriRemoveUser,
          data: {"userId": createdUserId},
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );

        if (response.statusCode != HttpStatus.ok)
          return Result.failure(
            AppError(
              AppErrorType.external,
              "The trainee wasn't created correctly, and we also encountered an error when trying to delete the associated user account.",
            ),
          );
      } catch (error) {
        return Result.failure(
          AppError(AppErrorType.internal, error.toString()),
        );
      } finally {
        print("[ERROR]: ${error.toString()}\n[STACK TRACE]: $st");
      }
    }

    return Result.failure(AppError(AppErrorType.internal, ""));
  }

  @override
  Future<Result<TraineeUserDao>> update(
    String id,
    TraineeUserUpdateDto dto,
  ) async {
    MysqlUtils? conn;
    try {
      conn = await MysqlConfiguration.connect();

      final existingRes = await getById(id);
      if (existingRes.isFailure)
        return Result.failure<TraineeUserDao>(existingRes.error!);

      final tempClass = existingRes.data!;

      final data = UpdateUtils.patchModel(tempClass.toJson(), dto.toJson());

      if (data.updatedFields.length == 0)
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.badRequest, 'No fields to update'),
        );

      data.patchedModel.addAll({'updatedAt': DateTime.now()});

      print('[PatchedModel] ${data.patchedModel}');
      print('[DTO] ${dto.toJson()}');
      print('[GetById Trainee] ${existingRes.data?.toJson() ?? "Vazio"}');

      final update = await conn.update(
        table: traineeUserTable,
        updateData: data.updatedFields,
        where: {'trainee_id': id},
      );

      if (update < BigInt.from(1))
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.internal, 'Update failed'),
        );

      final updated = TraineeUserDao.fromJson(data.patchedModel);
      return Result.success<TraineeUserDao>(updated);
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      return Result.failure<TraineeUserDao>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<TraineeUserDao>> delete(String id) async {
    MysqlUtils? conn;
    try {
      conn = await MysqlConfiguration.connect();

      final existingRes = await getById(id);
      if (existingRes.isFailure)
        return Result.failure<TraineeUserDao>(existingRes.error!);

      final tempClass = existingRes.data!;

      BigInt deleted = await conn.delete(
        table: table,
        where: {'trainee_id': id},
      );

      if (deleted == BigInt.zero)
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.internal, 'Delete failed'),
        );

      return Result.success<TraineeUserDao>(tempClass);
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return Result.failure<TraineeUserDao>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }
}
