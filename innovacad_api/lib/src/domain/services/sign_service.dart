import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signin_dto.dart';
import 'package:innovacad_api/src/domain/entities/user.dart';

abstract class ISignService {
  Future<Result<User>> signin(UserSigninDto dto);
}
