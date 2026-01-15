import 'dart:io';

import 'package:dio/dio.dart';
import 'package:innovacad_api/src/api/utils/token_utils.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/user/dto/signin/user_signin_dto.dart';
import 'package:vaden/vaden.dart' as v;

class SignInAdminResult {
  String? token;
  String? sessionToken;

  SignInAdminResult({this.token, this.sessionToken});
}

@v.Component()
class RemoteUserService {
  final v.ApplicationSettings _settings;
  final Dio _dio;

  RemoteUserService(this._settings, this._dio);

  Future<Result<SignInAdminResult>> signInAdmin() async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/sign-in/email",
      );

      final response = await _dio.postUri(
        uri,
        data: {
          "email": _settings["auth"]["admin_name"],
          "password": _settings["auth"]["admin_password"],
        },
      );

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(AppErrorType.external, "Admin sign-in failed"),
        );
      }
      final cookie = response.headers['set-cookie']!.toString();
      final token = TokenUtils.getUserToken(cookie);
      final sessionToken = TokenUtils.getUserSessionToken(cookie);

      if (token == null || sessionToken == null) {
        return Result.failure(
          AppError(AppErrorType.external, "Failed to retrieve admin token"),
        );
      }

      return Result.success(
        SignInAdminResult(token: token, sessionToken: sessionToken),
      );
    } catch (e) {
      return Result.failure(
        AppError(AppErrorType.external, "Admin sign-in error: $e"),
      );
    }
  }

  Future<Result<void>> deleteUserAsAdmin(String userId) async {
    final result = await signInAdmin();
    if (result.isFailure) return Result.failure(result.error!);

    final data = result.data!;

    try {
      final uriRemoveUser = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/admin/remove-user",
      );

      final response = await _dio.postUri(
        uriRemoveUser,
        data: {"userId": userId},
        options: Options(
          headers: {"Authorization": "Bearer ${data.sessionToken}"},
        ),
      );

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(AppErrorType.external, "Failed to delete user in Auth API"),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError(AppErrorType.external, "Delete user error: $e"),
      );
    }
  }

  Future<Result<Map<String, dynamic>>> signUpUser(
    String email,
    String name,
    String password,
  ) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/sign-up/email",
      );

      final response = await _dio.postUri(
        uri,
        data: {"email": email, "name": name, "password": password},
      );

      if (response.statusCode != HttpStatus.ok)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Auth API failed with status ${response.statusCode}",
          ),
        );

      final token = TokenUtils.getUserToken(response.headers["set-cookie"]![1]);
      if (token == null)
        return Result.failure(
          AppError(AppErrorType.external, "Failed to fetch user token"),
        );

      final userData = response.data["user"] as Map<String, dynamic>;
      userData["token"] = token;

      return Result.success(userData);
    } catch (e) {
      return Result.failure(
        AppError(AppErrorType.external, "SignUp error: $e"),
      );
    }
  }

  Future<Result<Map<String, dynamic>>> signInUser(UserSigninDto dto) async {
    try {
      final loginType = dto.email != null
          ? "email"
          : dto.username != null
          ? "username"
          : null;

      if (loginType == null) {
        return Result.failure(
          AppError(AppErrorType.badRequest, "Must provide email or username"),
        );
      }

      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/sign-in/$loginType",
      );

      final response = await _dio.postUri(
        uri,
        data: {
          "$loginType": loginType == "email" ? dto.email : dto.username,
          "password": dto.password,
        },
      );

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(AppErrorType.badRequest, "Sign-in failed"),
        );
      }

      final token = TokenUtils.getUserToken(response.headers['set-cookie']![1]);
      if (token == null) {
        return Result.failure(
          AppError(AppErrorType.external, "Failed to retrieve user token"),
        );
      }

      final userData = response.data["user"] as Map<String, dynamic>;
      userData["token"] = token;

      return Result.success(userData);
    } catch (e) {
      return Result.failure(
        AppError(AppErrorType.external, "SignIn error: $e"),
      );
    }
  }
}
