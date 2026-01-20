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
  Future<Response> getSession(@Header('cookie') String sessionCookie) async {
    final result = await _service.getSession(sessionCookie);

    return resultToResponse(result);
  }

  @Post('/in')
  Future<Response> signin(@Body() UserSigninDto dto) async {
    final result = await _service.signin(dto);
    print(result.headers);

    return resultToResponse(result, headers: result.headers);
  }

  @Post('/social/in')
  Future<Response> signinWithSocials(@Body() SigninSocialDto provider) async {
    final result = await _service.signinWithSocials(provider);

    return resultToResponse(result, headers: result.headers);
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
    final result = await _service.linkSocial(dto);
    return resultToResponse(result, headers: result.headers);
  }

  @Get("/accounts")
  Future<Response> listAccounts(@Header("cookie") String sessionToken) async {
    final result = await _service.listAccounts(sessionToken);
    return resultToResponse(result, headers: result.headers);
  }

  @Post("/send-otp")
  Future<Response> sendOTP(@Header('cookie') dynamic cookieHeader) async {
    final result = await _service.sendOTP(cookieHeader);

    return resultToResponse(result, headers: result.headers);
  }

  @Post("/verify-otp")
  Future<Response> verifyOTP(
    @Header('cookie') dynamic twoFactorCookie,
    @Query('otp') String otp,
  ) async {
    final result = await _service.verifyOTP(twoFactorCookie, otp);

    return resultToResponse(result, headers: result.headers);
  }
}
