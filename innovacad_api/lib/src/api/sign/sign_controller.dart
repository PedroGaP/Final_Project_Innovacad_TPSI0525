import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/user/dto/signin/user_signin_dto.dart';
import 'package:innovacad_api/src/data/user/service/sign_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'Sign', description: 'Authentication endpoints')
@Controller('/sign')
class SignController {
  final ISignService _service;

  SignController(this._service);

  @Post('/in')
  Future<Response> signin(@Body() UserSigninDto dto) async {
    final result = await _service.signin(dto);
    return resultToResponse(result);
  }
}
