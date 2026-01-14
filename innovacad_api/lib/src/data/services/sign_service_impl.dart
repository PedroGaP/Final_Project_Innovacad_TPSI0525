import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signin_dto.dart';
import 'package:innovacad_api/src/domain/entities/user.dart';
import 'package:innovacad_api/src/domain/repositories/sign_repository.dart';
import 'package:innovacad_api/src/domain/services/sign_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class SignServiceImpl extends ISignService {
  final ISignRepository _repository;
  SignServiceImpl(this._repository);

  @override
  Future<Result<User>> signin(UserSigninDto dto) async {
    return await this._repository.signin(dto);
  }
}
