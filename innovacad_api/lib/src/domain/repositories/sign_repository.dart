import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signin_dto.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signup_dto.dart';
import 'package:innovacad_api/src/domain/entities/user.dart';

abstract class ISignRepository {
  Future<Result<User>> signin(UserSigninDto dto);
  Future<Result<User>> signup(UserSignupDto dto);
}
