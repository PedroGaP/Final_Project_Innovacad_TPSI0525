import 'package:innovacad_api/src/core/http_mapper.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signin_dto.dart';
import 'package:innovacad_api/src/domain/dtos/user/user_signup_dto.dart';
import 'package:vaden/vaden.dart';
import 'package:innovacad_api/src/domain/services/sign_service.dart';

@Api(tag: 'Sign', description: 'AJDFDFJK')
@Controller('/sign')
class SignController {
  final ISignService _service;
  SignController(this._service);

  @Post('/in')
  Future<Response> signin(@Body() UserSigninDto dto) async {
    return resultToResponse(await this._service.signin(dto));
  }
}
