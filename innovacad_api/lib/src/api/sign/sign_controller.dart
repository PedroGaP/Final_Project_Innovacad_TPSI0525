import 'dart:convert';

import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/user/service/sign_service_impl.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'Sign', description: 'Authentication endpoints')
@Controller('/sign')
class SignController {
  final ISignService _service;

  SignController(this._service);

  //@Get('/session/<session-token>')
  @Get('/session')
  Future<Response> getSession(
    @Query('session-token') String sessionCookie,
  ) async {
    final result = await _service.getSession("sessionCookie");
    print(jsonEncode(result.data?.toJson()));

    return resultToResponse(result);
  }

  @Post('/in')
  Future<Response> signin(@Body() UserSigninDto dto) async {
    final result = await _service.signin(dto);

    print(jsonEncode(result.data?.toJson()));
    print(result.headers);
    return resultToResponse(result, headers: result.headers);
  }

  @Post('/social/in')
  Future<Response> signinWithSocials(@Body() SigninSocialDto provider) async {
    final result = await _service.signinWithSocials(provider);
    final headers = result.data!["headers"];
    result.data!.remove("headers");
    return resultToResponse(result, headers: headers);
  }

  @Post("/send/verify")
  Future<Response> sendVerifyEmail(@Body() SendVerifyEmailDto dto) async {
    final result = await _service.sendVerifyEmail(dto);
    return resultToResponse(result);
  }

  @Post("/verify")
  Future<Response> verifyEmail(@Body() VerifyEmailDto dto) async {
    final result = await _service.verifyEmail(dto);
    return resultToResponse(result);
  }

  @Post("/validity")
  Future<Response> checkEmailValidity(@Body() CheckEmailValidityDto dto) async {
    final result = await _service.checkEmailValidity(dto);
    return resultToResponse(result);
  }

  @Post("/link-social")
  Future<Response> linkSocial(@Body() UserLinkAccountDto dto) async {
    return resultToResponse(await _service.linkSocial(dto));
  }
}
