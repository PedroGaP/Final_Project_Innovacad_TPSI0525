import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/user/dto/reset_password/request_reset_password_dto.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'Sign', description: 'Authentication endpoints')
@Controller('/sign')
class SignController {
  final ISignService _service;

  SignController(this._service);

  @ApiOperation(
    summary: 'Get current session',
    description: 'Retrieves the current user session from cookie',
  )
  @ApiParam(name: 'cookie', description: 'Session cookie', required: true)
  @Get('/session')
  Future<Response> getSession(@Header('cookie') String sessionCookie) async {
    final result = await _service.getSession(sessionCookie);

    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Sign in with credentials',
    description: 'Authenticates user with email and password',
  )
  @Post('/in')
  Future<Response> signin(@Body() UserSigninDto dto) async {
    final result = await _service.signin(dto);
    print(result.headers);

    return resultToResponse(result, headers: result.headers);
  }

  @ApiOperation(
    summary: 'Sign in with social provider',
    description: 'Authenticates user with social provider',
  )
  @Post('/social/in')
  Future<Response> signinWithSocials(@Body() SigninSocialDto provider) async {
    final result = await _service.signinWithSocials(provider);

    return resultToResponse(result, headers: result.headers);
  }

  @ApiOperation(
    summary: 'Send email verification',
    description: 'Sends verification email to provided email address',
  )
  @Post("/send/verify")
  Future<Response> sendVerifyEmail(@Body() SendVerifyEmailDto dto) async {
    final result = await _service.sendVerifyEmail(dto);
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Verify email address',
    description: 'Verifies email with provided verification code',
  )
  @Post("/verify")
  Future<Response> verifyEmail(@Body() VerifyEmailDto dto) async {
    final result = await _service.verifyEmail(dto);
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Check email validity',
    description: 'Checks if email is valid and available',
  )
  @Post("/validity")
  Future<Response> checkEmailValidity(@Body() CheckEmailValidityDto dto) async {
    final result = await _service.checkEmailValidity(dto);
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Link social account',
    description: 'Links a social account to existing user account',
  )
  @Post("/link-social")
  Future<Response> linkSocial(@Body() UserLinkAccountDto dto) async {
    print(dto.token);
    final result = await _service.linkSocial(dto);
    return resultToResponse(result, headers: result.headers);
  }

  @ApiOperation(
    summary: 'List linked accounts',
    description: 'Retrieves all linked accounts for the user',
  )
  @ApiParam(
    name: 'sessionToken',
    description: 'Session token from cookie',
    required: true,
  )
  @Get("/accounts")
  Future<Response> listAccounts(@Header("cookie") String sessionToken) async {
    final result = await _service.listAccounts(sessionToken);
    return resultToResponse(result, headers: result.headers);
  }

  @ApiParam(
    name: 'cookieHeader',
    description: 'Session cookie',
    required: false,
  )
  @ApiOperation(
    summary: 'Send OTP for 2FA',
    description: 'Sends one-time password for two-factor authentication',
  )
  @Post("/send-otp")
  Future<Response> sendOTP(@Header('cookie') String? cookieHeader) async {
    print("Estou aqui $cookieHeader");

    final result = await _service.sendOTP(cookieHeader);

    return resultToResponse(result, headers: result.headers);
  }

  @ApiParam(name: 'otp', description: 'One-time password code', required: true)
  @ApiOperation(
    summary: 'Verify OTP code',
    description: 'Verifies one-time password for two-factor authentication',
  )
  @Post("/verify-otp")
  Future<Response> verifyOTP(
    @Header('cookie') dynamic twoFactorCookie,
    @Query('otp') String otp,
  ) async {
    final result = await _service.verifyOTP(twoFactorCookie, otp);

    return resultToResponse(result, headers: result.headers);
  }

  @ApiParam(
    name: 'password',
    description: 'User password for verification',
    required: true,
  )
  @ApiOperation(
    summary: 'Enable 2FA',
    description: 'Enables two-factor authentication for the account',
  )
  @Post("/enable-otp")
  Future<Response> enableOTP(
    @Header('cookie') dynamic cookies,
    @Query("password") String password,
  ) async {
    final result = await _service.enableOTP(cookies, password);

    return resultToResponse(result, headers: result.headers);
  }

  @ApiParam(
    name: 'password',
    description: 'User password for verification',
    required: true,
  )
  @ApiOperation(
    summary: 'Disable 2FA',
    description: 'Disables two-factor authentication for the account',
  )
  @Post("/disable-otp")
  Future<Response> disableOTP(
    @Header('cookie') dynamic cookies,
    @Query("password") String password,
  ) async {
    final result = await _service.disableOTP(cookies, password);

    return resultToResponse(result, headers: result.headers);
  }

  @Get("/is-otp-enabled")
  Future<Response> isOTPEnabled(@Query("user_id") String userId) async {
    final result = await _service.isOTPEnabled(userId);

    return resultToResponse(result, headers: result.headers);
  }

  @Post("/request-password-reset")
  Future<Response> requestPasswordReset(
    @Body() RequestResetPasswordDto dto,
  ) async {
    final result = await _service.requestPasswordReset(dto);
    return resultToResponse(result);
  }

  @Post("/reset-password")
  Future<Response> resetPassword(@Body() ResetPasswordDto dto) async {
    final result = await _service.resetPassword(dto);
    return resultToResponse(result);
  }
}
