import 'dart:io';

import 'package:dio/dio.dart';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/api/utils/token_utils.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:mysql_utils/mysql_utils.dart';
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

      final res = await _dio.get(
        'http://localhost:10000/api/auth/get-session',
        options: Options(
          headers: {"cookie": response.headers["set-cookie"]![0]},
        ),
      );

      if (res.statusCode != 200)
        return Result.failure(
          AppError(AppErrorType.notFound, "No session found?"),
        );

      final userData = res.data["user"] as Map<String, dynamic>;
      userData["token"] = token;
      userData["headers"] = {"set-cookie": res.headers["set-cookie"]![0]};

      return Result.success(userData, headers: userData["headers"]);
    } catch (e, s) {
      print(s);
      return Result.failure(
        AppError(AppErrorType.external, "SignIn error: $e"),
      );
    }
  }

  Future<Result<Map<String, dynamic>>> signInUserWithSocials(
    SigninSocialDto dto,
  ) async {
    try {
      final validProvider = dto.provider == "google"
          ? "google"
          : dto.provider == "facebook"
          ? "facebook"
          : null;

      if (validProvider == null) {
        return Result.failure(
          AppError(
            AppErrorType.badRequest,
            "Must provide a valid auth provider....",
          ),
        );
      }

      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/sign-in/social",
      );

      final response = await _dio.postUri(
        uri,
        data: {"provider": validProvider, "callbackURL": dto.callback},
      );

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(AppErrorType.badRequest, "Sign-in failed.."),
        );
      }

      // final cookie = response.headers['set-cookie'].toString();
      // final token = TokenUtils.getUserToken(cookie);

      // if (token == null)
      //   return Result.failure(
      //     AppError(AppErrorType.external, "Failed to retrieve user token"),
      //   );

      print(response.data);
      //final userData = response.data["user"] as Map<String, dynamic>;
      // userData["token"] = token;
      final res = response.data;
      res["headers"] = {"set-cookie": response.headers["set-cookie"]![0]};

      return Result.success(response.data);
    } catch (e, s) {
      print(s);
      return Result.failure(
        AppError(AppErrorType.external, "SignIn error: $e"),
      );
    }
  }

  Future<Result<bool>> linkSocial(UserLinkAccountDto dto) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/link-social",
      );

      final response = await _dio.postUri(
        uri,
        data: {"provider": dto.provider, "callbackURL": dto.callback},
      );

      if (response.statusCode != HttpStatus.ok)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Failed to link your social account...",
            details: {"status": response.statusCode},
          ),
        );

      return Result.success(true);
    } catch (e) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while trying to link the user social account...",
          details: {"error": e.toString()},
        ),
      );
    }
  }

  Future<Result<bool>> sendVerifyEmail(SendVerifyEmailDto dto) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/send-verification-email",
      );

      final response = await _dio.postUri(
        uri,
        data: {"email": dto.email},
        options: Options(
          headers: {"set-cookie": "better-auth.session_data=${dto.token}"},
        ),
      );

      // print(response.data);
      // print(dto.email);
      // print(dto.token);

      if (response.statusCode != HttpStatus.ok)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Better Auth failed to send verification to the user email...",
            details: {"status": response.statusCode},
          ),
        );

      return Result.success(response.data!["status"]);
    } catch (e) {
      Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong in the verification process...",
          details: {"error": e.toString()},
        ),
      );
    }
    return Result.success(false);
  }

  Future<Result<bool>> verifyEmail(VerifyEmailDto dto) async {
    try {
      print(dto.callback);

      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/verify-email",
        query: "token=${dto.verifyToken}&callbackURL=${dto.callback}",
      );

      final response = await _dio.getUri(
        uri,
        options: Options(
          headers: {"set-cookie": "better-auth.session_data=${dto.authToken}"},
        ),
      );

      if (response.statusCode != HttpStatus.ok)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Better Auth failed to verify the user email...",
            details: {"status": response.statusCode},
          ),
        );

      return Result.success(response.data!["status"]);
    } catch (e) {
      Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong in the verification process...",
          details: {"error": e.toString()},
        ),
      );
    }
    return Result.success(false);
  }

  Future<Result<bool>> checkEmailValidity(CheckEmailValidityDto dto) async {
    try {
      MysqlUtils db = await MysqlConfiguration.connect();

      final res = await db.getOne(
        table: 'user',
        where: {'id': dto.userId},
        debug: true,
      );

      if (res.isEmpty) {
        return Result.failure(
          AppError(AppErrorType.notFound, "No user found."),
        );
      }

      if (!res.containsKey("emailVerified") || res["emailVerified"] != true) {
        return Result.failure(
          AppError(
            AppErrorType.internal,
            "An error occured while verifying email.",
          ),
        );
      }

      return Result.success(res["emailVerified"]);
    } catch (e) {
      Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong in the verification process...",
          details: {"error": e.toString()},
        ),
      );
    }
    return Result.success(false);
  }

  Future<Result<OutputUserDao>> getSession(String sessionCookie) async {
    try {
      final res = await _dio.get("http://localhost:10000/api/auth/get-session");

      if (res.statusCode != 200 || res.data == null)
        return Result.failure(
          AppError(
            AppErrorType.notFound,
            "No session found, sign in and try again later.",
          ),
        );

      return Result.success(res.data);
    } catch (e, s) {
      print(s);
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
