import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/user/dto/reset_password/request_reset_password_dto.dart';
import 'package:innovacad_api/src/data/user/dto/reset_password/reset_password_dto.dart';
import 'package:vaden/vaden.dart' as v;

abstract class ISignService {
  Future<Result<dynamic>> signin(UserSigninDto dto);
  Future<Result<Map<String, dynamic>>> signinWithSocials(SigninSocialDto dto);
  Future<Result<bool>> verifyEmail(VerifyEmailDto dto);
  Future<Result<bool>> sendVerifyEmail(SendVerifyEmailDto dto);
  Future<Result<bool>> checkEmailValidity(CheckEmailValidityDto dto);
  Future<Result<Map<String, dynamic>>> linkSocial(UserLinkAccountDto dto);
  Future<Result<OutputUserDao>> getSession(String sessionToken);
  Future<Result<List<Map<String, dynamic>>>> listAccounts(String sessionToken);
  Future<Result<bool>> sendOTP(dynamic twoFactorCode);
  Future<Result<Map<String, dynamic>>> verifyOTP(
    dynamic twoFactorCookie,
    String otp,
  );
  Future<Result<bool>> enableOTP(dynamic cookies, String password);
  Future<Result<bool>> disableOTP(dynamic cookies, String password);
  Future<Result<bool>> isOTPEnabled(String userId);
  Future<Result<bool>> requestPasswordReset(RequestResetPasswordDto dto);
  Future<Result<bool>> resetPassword(ResetPasswordDto dto);
}

@v.Service()
class SignServiceImpl implements ISignService {
  final RemoteUserService _remoteUserService;

  SignServiceImpl(this._remoteUserService);

  @override
  Future<Result<dynamic>> signin(UserSigninDto dto) async {
    final authResult = await _remoteUserService.signInUser(dto);
    if (authResult.isFailure) return Result.failure(authResult.error!);

    if (authResult.data!.containsKey('twoFactorRedirect')) {
      return authResult;
    }

    final role = authResult.data!["role"];

    OutputUserDao? user;

    if (role == 'admin') user = OutputUserDao.fromJson(authResult.data!);

    if (role == 'trainer') user = OutputTrainerDao.fromJson(authResult.data!);

    if (role == 'trainee') user = OutputTraineeDao.fromJson(authResult.data!);

    if (user != null) {
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print(authResult.headers);
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      return Result.success(user, headers: authResult.headers);
    }

    return Result.failure(
      AppError(
        AppErrorType.unauthorized,
        "The provided user doesn't have a application use associated.",
      ),
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> signinWithSocials(
    SigninSocialDto dto,
  ) async {
    final authResult = await _remoteUserService.signInUserWithSocials(dto);
    if (authResult.isFailure) return Result.failure(authResult.error!);

    return Result.success(authResult.data!, headers: authResult.headers);
  }

  @override
  Future<Result<bool>> verifyEmail(VerifyEmailDto dto) async {
    final result = await _remoteUserService.verifyEmail(dto);
    if (result.isFailure) return Result.success(false);

    return Result.success(result.data!);
  }

  @override
  Future<Result<bool>> sendVerifyEmail(SendVerifyEmailDto dto) async {
    final result = await _remoteUserService.sendVerifyEmail(dto);
    if (result.isFailure) return Result.success(false);

    return Result.success(result.data!);
  }

  @override
  Future<Result<bool>> checkEmailValidity(CheckEmailValidityDto dto) async {
    // TODO: implement checkEmailValidity
    final result = await _remoteUserService.checkEmailValidity(dto);
    if (result.isFailure) return Result.success(false);

    return Result.success(result.data!);
  }

  @override
  Future<Result<Map<String, dynamic>>> linkSocial(
    UserLinkAccountDto dto,
  ) async {
    return await _remoteUserService.linkSocial(dto);
  }

  @override
  Future<Result<OutputUserDao>> getSession(String sessionCookie) async {
    final result = await _remoteUserService.getSession(sessionCookie);

    return result;
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> listAccounts(
    String sessionToken,
  ) async {
    final result = await _remoteUserService.listAccounts(sessionToken);

    return result;
  }

  @override
  Future<Result<bool>> sendOTP(dynamic twoFactorCode) async {
    final result = await _remoteUserService.sendOTP(twoFactorCode);

    return result;
  }

  @override
  Future<Result<Map<String, dynamic>>> verifyOTP(
    dynamic twoFactorCookie,
    String otp,
  ) async {
    final result = await _remoteUserService.verifyOTP(twoFactorCookie, otp);

    return result;
  }

  @override
  Future<Result<bool>> enableOTP(dynamic cookies, String password) async {
    return await _remoteUserService.enableOTP(cookies, password);
  }

  @override
  Future<Result<bool>> disableOTP(dynamic cookies, String password) async {
    return await _remoteUserService.disableOTP(cookies, password);
  }

  @override
  Future<Result<bool>> isOTPEnabled(String userId) async {
    return await _remoteUserService.isOTPEnabled(userId);
  }

  @override
  Future<Result<bool>> requestPasswordReset(RequestResetPasswordDto dto) async {
    final result = await _remoteUserService.requestPasswordReset(dto);
    if (result.isFailure) return Result.failure(result.error!);
    return Result.success(result.data!);
  }

  @override
  Future<Result<bool>> resetPassword(ResetPasswordDto dto) async {
    final result = await _remoteUserService.resetPassword(dto);

    if (result.isFailure) return Result.failure(result.error!);

    return Result.success(result.data!);
  }
}
