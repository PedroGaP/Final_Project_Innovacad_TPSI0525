import 'dart:io';

import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/api/utils/token_utils.dart';
import 'package:innovacad_api/src/data/repositories/sign_repository_impl.dart';
import 'package:innovacad_api/src/domain/daos/trainer/trainer_user_dao.dart';
import 'package:innovacad_api/src/domain/dtos/trainer/trainer_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainer/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signin_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:innovacad_api/src/domain/repositories/trainer_repository.dart';
import 'package:innovacad_api/src/core/result.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart' as v;
import 'package:dio/dio.dart';

@v.Repository()
class TrainerRepositoryImpl implements ITrainerRepository {
  final String table = "trainers";
  final v.ApplicationSettings _settings;
  final Dio _dio;

  TrainerRepositoryImpl(this._settings, this._dio);

  @override
  Future<Result<List<Trainer>>> getAll() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Trainer>> getById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<TrainerUserDao>> create(TrainerCreateDto dto) async {
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

      var rawTrainerMap = response.data["user"];
      var cleanedTrainerMap = {
        "id": rawTrainerMap["id"],
        "email": rawTrainerMap["email"] ?? dto.email,
        "username": rawTrainerMap["username"] ?? dto.username,
        "name": rawTrainerMap["name"] ?? dto.name,
        "trainer_id": null,
        "createdAt": rawTrainerMap["createdAt"],
        "birthday_date": dto.birthdayDate,
        "specialization": dto.specialization,
        "token": token,
        "role": null,
        "image": null,
      };

      createdUserId = cleanedTrainerMap["id"];

      db = await MysqlConfiguration.connect();

      // 3. Update the created user with the missing fields

      final role = "trainer";

      final updateCount = await db.update(
        table: "user",
        updateData: {"username": dto.username, "role": role},
        where: {"id": createdUserId},
      );

      cleanedTrainerMap["role"] = role;

      if (updateCount == BigInt.from(0))
        throw "Failed to update the missing fileds for the created user.";

      // 4. Start the transaction that will commit the trainer changes

      await db.startTrans();

      // 5. Create the trainer for the created user

      await db.insert(
        table: table,
        insertData: {
          "user_id": createdUserId,
          "specialization": cleanedTrainerMap["specialization"],
          "birthday_date": cleanedTrainerMap["birthday_date"],
        },
      );

      // 6. Verify if the trainer was successfully created

      final dbRawTrainer =
          await db.getOne(table: table, where: {"user_id": createdUserId})
              as Map<String, dynamic>;
      cleanedTrainerMap["trainer_id"] = dbRawTrainer["trainer_id"];

      Trainer.fromJson(
        cleanedTrainerMap,
      ); // This throws an error if it fails its all good :)

      // 8. Commit the trainer changes

      await db.commit();

      // 9. Return the trainer dao

      return Result.success(TrainerUserDao.fromJson(cleanedTrainerMap));
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
              "The trainer wasn't created correctly, and we also encountered an error when trying to delete the associated user account.",
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
  Future<Result<Trainer>> update(String id, TrainerUpdateDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Trainer>> delete(String id) async {
    throw UnimplementedError();
  }
}
