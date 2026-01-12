import 'dart:io';
import 'package:dio/dio.dart';
import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signup_dto.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signin_dto.dart';
import 'package:innovacad_api/src/domain/entities/user.dart';
import 'package:innovacad_api/src/domain/repositories/sign_repository.dart';
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

    try {
      Response res = await _dio.postUri(
        uri,
        data: {
          "$loginType": loginType.contains("email") ? dto.email : dto.username,
          "password": dto.password,
        },
      );

      if (res.statusCode != HttpStatus.ok)
        return Result.failure<User>(
          AppError(
            AppErrorType.badRequest,
            "Something went wrong, please try to sign-in again.",
          ),
        );

      final user = User.fromJson(res.data["user"]);
      user.token = res.data['token'];

      final String cookie = res.headers['set-cookie']![1];
      final regexp = RegExp(
        '(?<=better-auth\.session_data=)(?<header>[^.]+)\.(?<payload>[^.]+)\.(?<signature>[^;]+)',
      );
      final parsedToken = regexp.firstMatch(cookie);

      if (parsedToken == null)
        return Result.failure<User>(
          AppError(
            AppErrorType.external,
            'Received token is invalid on RegExp.',
            details: {'string': cookie},
          ),
        );

      user.token = parsedToken.group(0);

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

  @override
  Future<Result<User>> signup(UserSignupDto dto) async {
    final uri = new Uri(
      scheme: _settings["auth"]["protocol"],
      host: _settings["auth"]["host"],
      port: _settings["auth"]["port"],
      path: "/api/auth/sign-up/email",
    );

    try {
      Response res = await _dio.postUri(uri, data: {});

      if (res.statusCode != HttpStatus.ok)
        return Result.failure<User>(
          AppError(
            AppErrorType.badRequest,
            'Error while creating user',
            details: res.data,
          ),
        );

      final user = User.fromJson(res.data["user"]);

      return Result.success<User>(user);
    } on DioException catch (e, s) {
      print(e);
      print(s);
      return Result.failure<User>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }
}
