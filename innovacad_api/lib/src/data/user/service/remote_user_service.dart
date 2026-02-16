import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/api/utils/token_utils.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/user/dto/reset_password/request_reset_password_dto.dart';
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
  final String table = "user";

  RemoteUserService(this._settings, this._dio);

  Future<Map<String, dynamic>> _enrichWithLocalData(
    Map<String, dynamic> userData,
  ) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final userId = userData['id'];

      final trainerRow = await db.getOne(
        table: 'trainers',
        where: {'user_id': userId},
      );

      if (trainerRow.isNotEmpty) {
        final String trainerId = trainerRow['trainer_id'].toString();
        userData['trainer_id'] = trainerId;
        userData['birthday_date'] = trainerRow['birthday_date'];

        if (userData['role'] == 'user') userData['role'] = 'trainer';

        final classesResult = await db.query(
          "SELECT class_id FROM trainers_classes_coordinator WHERE trainer_id = ?",
          whereValues: [trainerId],
          isStmt: true,
        );

        Map<String, String> coordinatedIds = Map.fromEntries(
          classesResult.rows.map(
            (row) => MapEntry(
              row['class_id'].toString(),
              row['identifier'].toString(),
            ),
          ),
        );

        userData['is_coordinator'] = coordinatedIds.isNotEmpty;
        userData['coordinated_class_ids'] = coordinatedIds;

        final skillsResult = await db.query(
          "SELECT module_id, competence_level FROM trainer_skills WHERE trainer_id = ?",
          whereValues: [trainerId],
          isStmt: true,
        );

        userData['skills'] = skillsResult.rowsAssoc
            .map((row) => row.assoc())
            .toList();
      } else {
        final traineeRow = await db.getOne(
          table: 'trainees',
          where: {'user_id': userId},
        );

        if (traineeRow.isNotEmpty) {
          userData['trainee_id'] = traineeRow['trainee_id'].toString();
          userData['birthday_date'] = traineeRow['birthday_date'];

          if (userData['role'] == 'user') userData['role'] = 'trainee';
        }
      }

      if (userData['role'] == 'coordinator') {
        userData['is_coordinator'] = true;
        userData['coordinated_class_ids'] =
            userData['coordinated_class_ids'] ?? [];
      }

      return userData;
    } catch (e) {
      return userData;
    }
  }

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
    String username,
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
        data: {
          "email": email,
          "name": name,
          "password": password,
          "username": username,
        },
      );

      if (response.statusCode != HttpStatus.ok)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Auth API failed with status ${response.statusCode}",
          ),
        );

      final cookies = response.headers["set-cookie"];
      if (cookies == null || cookies.isEmpty) {
        return Result.failure(
          AppError(AppErrorType.external, "No cookies returned"),
        );
      }

      final rawCookie = cookies.length > 1 ? cookies[1] : cookies[0];

      final token = TokenUtils.getUserToken(rawCookie);

      if (response.data["user"] == null) {
        return Result.failure(
          AppError(AppErrorType.external, "API returned no user object"),
        );
      }

      final userData = Map<String, dynamic>.from(response.data["user"] as Map);

      if (userData["id"] == null) {
        return Result.failure(
          AppError(AppErrorType.external, "API returned user without ID"),
        );
      }

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
          AppError(
            AppErrorType.badRequest,
            "Sign-in failed",
            details: response.data,
          ),
        );
      }

      if (response.data is Map &&
          response.data.containsKey("twoFactorRedirect")) {
        return Result.success(
          response.data,
          headers: {"set-cookie": response.headers['set-cookie']},
        );
      }

      final token = TokenUtils.getUserToken(response.headers['set-cookie']![1]);
      if (token == null) {
        return Result.failure(
          AppError(AppErrorType.external, "Failed to retrieve user token"),
        );
      }

      final signInCookies = response.headers['set-cookie'] ?? [];

      final res = await _dio.get(
        'http://localhost:10000/api/auth/get-session',
        options: Options(headers: {"cookie": signInCookies}),
      );

      if ((res.statusCode != HttpStatus.ok || res.data == null) &&
          response.data['user'] != null) {
        var userData = response.data['user'] as Map<String, dynamic>;
        userData["token"] = token;

        if (response.data['session'] != null) {
          userData["session_token"] = response.data['session']['token'];
        }

        userData = await _enrichWithLocalData(userData);

        return Result.success(userData, headers: {"set-cookie": signInCookies});
      }

      if (res.statusCode != HttpStatus.ok || res.data == null) {
        return Result.failure(
          AppError(
            AppErrorType.notFound,
            "No session found for user",
            details: response.data,
          ),
        );
      }

      var userData = res.data["user"] as Map<String, dynamic>;

      userData["session_token"] = res.data["session"]["token"];
      userData["token"] = token;
      userData["headers"] = {"set-cookie": res.headers["set-cookie"]};

      userData = await _enrichWithLocalData(userData);

      final sessionCookies = res.headers['set-cookie'] ?? [];
      final allCookies = [...signInCookies, ...sessionCookies];

      return Result.success(userData, headers: {"set-cookie": allCookies});
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.external,
          "SignIn error: $e",
          details: {"error": s.toString()},
        ),
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
          AppError(
            AppErrorType.badRequest,
            "Sign-in failed..",
            details: {
              ...response.data,
              "status": response.statusCode,
              ...response.requestOptions.data,
            },
          ),
        );
      }

      return Result.success(
        response.data,
        headers: {"set-cookie": response.headers["set-cookie"]![0]},
      );
    } catch (e, _) {
      return Result.failure(
        AppError(AppErrorType.external, "SignIn error: $e"),
      );
    }
  }

  Future<Result<Map<String, dynamic>>> linkSocial(
    UserLinkAccountDto dto,
  ) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/link-social",
      );

      final response = await _dio.postUri(
        uri,
        options: Options(headers: {"Authorization": 'Bearer ${dto.token}'}),
        data: {"provider": dto.provider, "callbackURL": dto.callback},
      );

      if (response.statusCode != HttpStatus.ok)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Failed to link your social account...",
            details: {"status": response.statusCode, "data": response.data},
          ),
        );

      return Result.success(
        response.data,
        headers: {"set-cookie": response.headers["set-cookie"]![0]},
      );
    } catch (e, s) {
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
        debug: false,
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
      final res = await _dio.get(
        "http://localhost:10000/api/auth/get-session",
        options: Options(
          headers: {
            "cookie": sessionCookie,
            "Content-Type": "application/json",
          },
          validateStatus: (status) => true,
        ),
      );

      if (res.statusCode != 200 || res.data == null) {
        return Result.failure(
          AppError(
            AppErrorType.notFound,
            "No session found (Better Auth refused).",
            details: {"status": res.statusCode, "data": res.data},
          ),
        );
      }

      dynamic rawData = res.data;
      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData['user'] == null) {
        return Result.failure(
          AppError(
            AppErrorType.notFound,
            "Session valid but no user data found",
          ),
        );
      }

      var userData = Map<String, dynamic>.from(rawData['user']);

      String cookieHeader = "";
      if (res.headers['set-cookie'] != null &&
          res.headers['set-cookie']!.isNotEmpty) {
        cookieHeader = res.headers['set-cookie']!.join('; ');
      }
      if (cookieHeader.isEmpty) cookieHeader = sessionCookie;

      userData["session_token"] = rawData["session"]?["token"];
      userData["token"] = TokenUtils.getUserToken(cookieHeader);

      userData = await _enrichWithLocalData(userData);

      try {
        final db = await MysqlConfiguration.connect();
        final user = await db.getOne(
          table: 'user',
          where: {'id': userData['id']},
        );
        if (user.isNotEmpty && user['image'] != null) {
          userData['image'] = user['image'];
        }
        await MysqlConfiguration.closeConnection(db);
      } catch (_) {}

      final role = userData['role'];

      if ((role == 'trainer' || role == 'coordinator') &&
          userData.containsKey('trainer_id') &&
          userData['trainer_id'] != null) {
        return Result.success(OutputTrainerDao.fromJson(userData));
      }

      if (role == 'trainee' &&
          userData.containsKey('trainee_id') &&
          userData['trainee_id'] != null) {
        try {
          return Result.success(OutputTraineeDao.fromJson(userData));
        } catch (_) {}
      }

      return Result.success(OutputUserDao.fromJson(userData));
    } catch (e, _) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  Future<Result<bool>> updateUser(String id, UpdateUserDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      Map<String, dynamic> data = {};

      if (dto.name != null) data["name"] = dto.name;
      if (dto.image != null) data["image"] = dto.image;

      if (data.length == 0) return Result.success(true);

      final res = await db.update(
        table: table,
        updateData: data,
        where: {"id": id},
        debug: false,
      );

      if (res < BigInt.one) return Result.success(true);

      return Result.success(true);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Failed to update the user",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }

  Future<Result<List<Map<String, dynamic>>>> listAccounts(
    String sessionToken,
  ) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/list-accounts",
      );
      final response = await _dio.getUri(
        uri,
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${TokenUtils.getUserSessionToken(sessionToken)}',
          },
        ),
      );

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(
            AppErrorType.badRequest,
            "Failed to list user accounts.",
            details: {"status": response.statusCode, "message": response.data},
          ),
        );
      }

      List<dynamic> resData = response.data!;

      List<Map<String, dynamic>> accounts = resData
          .map((e) => OutputAccountDao.fromJson(e).toJson())
          .toList();

      return Result.success(accounts);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"error": s.toString()},
        ),
      );
    }
  }

  Future<Result<bool>> sendOTP(dynamic cookies) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/two-factor/send-otp",
      );
      final response = await _dio.postUri(
        uri,
        options: Options(
          headers: {
            'cookie': cookies is List ? cookies.join(";") : cookies,
            "origin": "http://localhost:8080",
          },
        ),
      );

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(
            AppErrorType.badRequest,
            "Failed to send email OTP.",
            details: {"status": response.statusCode, "message": response.data},
          ),
        );
      }

      final newCookies = response.headers["set-cookie"] ?? cookies;

      return Result.success(
        response.data["status"],
        headers: {"set-cookie": newCookies},
      );
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"error": s.toString()},
        ),
      );
    }
  }

  Future<Result<Map<String, dynamic>>> verifyOTP(
    dynamic twoFactorCookie,
    String otp,
  ) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/two-factor/verify-otp",
      );
      final response = await _dio.postUri(
        uri,
        data: {"code": otp},
        options: Options(
          headers: {
            "origin": "http://localhost:8080",
            "cookie": twoFactorCookie is List
                ? twoFactorCookie.join(";")
                : twoFactorCookie,
          },
        ),
      );

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(
            AppErrorType.badRequest,
            "Failed to send email OTP.",
            details: {"status": response.statusCode, "message": response.data},
          ),
        );
      }

      final sessionResponse = await getSession(
        response.headers["set-cookie"]![0],
      );

      if (sessionResponse.isFailure || sessionResponse.data == null) {
        return Result.failure(
          AppError(
            AppErrorType.notFound,
            "No session found for user",
            details: {"data": sessionResponse.data},
          ),
        );
      }

      return Result.success(
        sessionResponse.data!.toJson(),
        headers: {"set-cookie": response.headers["set-cookie"]},
      );
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"error": s.toString()},
        ),
      );
    }
  }

  Future<Result<bool>> enableOTP(dynamic cookies, String password) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/two-factor/enable",
      );

      final response = await _dio.postUri(
        uri,
        data: {"password": password},
        options: Options(
          headers: {
            'cookie': cookies is List ? cookies.join(";") : cookies,
            "origin": "http://localhost:8080",
          },
        ),
      );

      if (response.statusCode != HttpStatus.ok)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Failed to enable the 2FA",
            details: {"status": response.statusCode},
          ),
        );

      return Result.success(true);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"error": s.toString()},
        ),
      );
    }
  }

  Future<Result<bool>> disableOTP(dynamic cookies, String password) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/two-factor/disable",
      );

      final response = await _dio.postUri(
        uri,
        data: {"password": password},
        options: Options(
          headers: {
            'cookie': cookies is List ? cookies.join(";") : cookies,
            "origin": "http://localhost:8080",
          },
        ),
      );

      if (response.statusCode != HttpStatus.ok)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Failed to disable the 2FA",
            details: {"status": response.statusCode},
          ),
        );

      return Result.success(response.data["status"]);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"error": s.toString()},
        ),
      );
    }
  }

  Future<Result<bool>> isOTPEnabled(String userId) async {
    try {
      MysqlUtils db = await MysqlConfiguration.connect();

      final user =
          await db.getOne(table: "user", where: {"id": userId})
              as Map<String, dynamic>;

      if (user.isEmpty)
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Failed to fetch the user with the id $userId",
          ),
        );

      return Result.success(user["twoFactorEnabled"]);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"error": s.toString()},
        ),
      );
    }
  }

  Future<Result<bool>> requestPasswordReset(RequestResetPasswordDto dto) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/request-password-reset",
      );

      final data = {"email": dto.email, "redirectTo": dto.redirectTo};

      final response = await _dio.postUri(uri, data: data);

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Failed to send password reset email.",
            details: {"status": response.statusCode, "message": response.data},
          ),
        );
      }

      return Result.success(response.data["status"] ?? true);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error requesting password reset: $e",
          details: {"error": s.toString()},
        ),
      );
    }
  }

  Future<Result<bool>> resetPassword(ResetPasswordDto dto) async {
    try {
      final uri = Uri(
        scheme: _settings["auth"]["protocol"],
        host: _settings["auth"]["host"],
        port: _settings["auth"]["port"],
        path: "/api/auth/reset-password",
      );

      final data = {"newPassword": dto.newPassword, "token": dto.token};

      final response = await _dio.postUri(uri, data: data);

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(
            AppErrorType.external,
            "Failed to reset password.",
            details: {"status": response.statusCode, "message": response.data},
          ),
        );
      }

      return Result.success(response.data["status"] ?? true);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error resetting password: $e",
          details: {"error": s.toString()},
        ),
      );
    }
  }
}
