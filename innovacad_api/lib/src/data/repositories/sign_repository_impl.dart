import 'dart:io';
import 'package:dio/dio.dart';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/api/utils/token_utils.dart';
import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signin_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainee.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:innovacad_api/src/domain/entities/user.dart';
import 'package:innovacad_api/src/domain/repositories/sign_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart' as v;

@v.Repository()
class SignRepositoryImpl extends ISignRepository {
  final v.ApplicationSettings _settings;
  final Dio _dio;

  SignRepositoryImpl(this._settings, this._dio);

  @override
  Future<Result<User>> signin(UserSigninDto dto) async {
    final loginType = dto.email != null
        ? "email"
        : dto.username != null
        ? "username"
        : null;

    if (loginType == null)
      return Result.failure<User>(
        AppError(
          AppErrorType.badRequest,
          "The login type must be email or username.",
        ),
      );

    final uri = new Uri(
      scheme: _settings["auth"]["protocol"],
      host: _settings["auth"]["host"],
      port: _settings["auth"]["port"],
      path: "/api/auth/sign-in/$loginType",
    );

    MysqlUtils? db;

    try {
      Response response = await _dio.postUri(
        uri,
        data: {
          "$loginType": loginType.contains("email") ? dto.email : dto.username,
          "password": dto.password,
        },
      );

      if (response.statusCode != HttpStatus.ok)
        return Result.failure<User>(
          AppError(
            AppErrorType.badRequest,
            "Something went wrong, please try to sign-in again.",
          ),
        );

      db = await MysqlConfiguration.connect();

      final token = TokenUtils.getUserToken(response.headers['set-cookie']![1]);

      if (token == null)
        return Result.failure(
          AppError(AppErrorType.external, "Failed to grab the user token"),
        );

      final userId = response.data["user"]["id"];
      final traineeResultFuture = db.getOne(
        table: 'trainees',
        fields: 'trainee_id, user_id, birthday_date',
        where: {'user_id': userId},
      );

      final trainerResultFuture = db.getOne(
        table: 'trainers',
        fields: 'trainer_id, user_id, birthday_date, specialization',
        where: {'user_id': userId},
      );

      final results = await Future.wait([
        trainerResultFuture,
        traineeResultFuture,
      ]);

      List<Map<String, dynamic>> comb = results
          .map((r) => r.map((key, value) => MapEntry(key.toString(), value)))
          .toList();

      print(comb.toString());
      print(userId);

      if (comb.isEmpty || (comb.first.isEmpty && comb[1].isEmpty))
        return Result.success(User.fromJson(response.data["user"]));

      final data = <String, dynamic>{};
      data.addAll(
        comb.firstWhere(
          (e) => e.containsKey('trainee_id') || e.containsKey('trainer_id'),
        ),
      );
      data.addAll(response.data["user"]);

      final user = data.containsKey('trainee_id')
          ? Trainee.fromJson(data)
          : Trainer.fromJson(data);
      user.token = token;

      return Result.success<User>(user);
    } on DioException catch (e, s) {
      print("[ERROR]: $e\n[STACK]: $s");
      return Result.failure(
        AppError(
          AppErrorType.external,
          "Database Error",
          details: {"error": e.toString()},
        ),
      );
    }
  }
}
