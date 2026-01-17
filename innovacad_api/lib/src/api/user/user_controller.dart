import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Controller('/user')
class UserController {
  final IUserService _service;

  UserController(this._service);

  /*@Post('link-account')
  Future<Response> linkUserAccount(@Body() UserLinkAccountDto dto) async {
    Result<OutputUserDao> result = await _service.linkAccount(dto);
    return resultToResponse();
  }*/
}
