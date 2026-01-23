import 'dart:io';

import 'package:innovacad_mobile/config/dio_config.dart';
import 'package:innovacad_mobile/models/user_model.dart';
import 'package:innovacad_mobile/utils/result.dart';

class SignInRepository {
  Future<Result<UserModel?>> signInWithEmail(
    String email,
    String password,
  ) async {
    UserModel? user;
    try {
      final response = await DioConfig.dio.post(
        "/sign/in",
        data: {"email": email, "password": password},
      );

      if (response.statusCode != HttpStatus.ok) {
        return Result.failure(
          AppError(
            message: "Something went wrong",
            details: response.data is Map ? {...response.data} : response.data,
          ),
        );
      }

      user = UserModel.fromJson(response.data);

      return Result.success(user);
    } catch (e, s) {
      print(e);
      print(s);
      return Result.failure(
        AppError(
          message: "Something went wrong",
          details: {"error": e.toString(), "stack": s.toString()},
        ),
      );
    }
  }
}
