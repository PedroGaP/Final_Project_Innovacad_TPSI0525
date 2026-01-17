import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart' as v;

abstract class ISignService {
  Future<Result<OutputUserDao>> signin(UserSigninDto dto);
  Future<Result<Map<String, dynamic>>> signinWithSocials(SigninSocialDto dto);
  Future<Result<bool>> verifyEmail(VerifyEmailDto dto);
  Future<Result<bool>> sendVerifyEmail(SendVerifyEmailDto dto);
  Future<Result<bool>> checkEmailValidity(CheckEmailValidityDto dto);
  Future<Result<bool>> linkSocial(UserLinkAccountDto dto);
  Future<Result<OutputUserDao>> getSession(String sessionCookie);
}

@v.Service()
class SignServiceImpl implements ISignService {
  final RemoteUserService _remoteUserService;

  SignServiceImpl(this._remoteUserService);

  @override
  Future<Result<OutputUserDao>> signin(UserSigninDto dto) async {
    final authResult = await _remoteUserService.signInUser(dto);
    if (authResult.isFailure) return Result.failure(authResult.error!);

    final role = authResult.data!["role"];

    OutputUserDao? user;

    if (role == 'admin') user = OutputUserDao.fromJson(authResult.data!);

    if (role == 'trainer') user = OutputTrainerDao.fromJson(authResult.data!);

    if (role == 'trainee') user = OutputTraineeDao.fromJson(authResult.data!);

    if (user != null) {
      return Result.success(user, headers: authResult.headers);
    }

    return Result.failure(
      AppError(
        AppErrorType.unauthorized,
        "The provided user doesn't have a application use associated.",
      ),
    );

    /* MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final results = await Future.wait([
        db.getOne(
          table: 'trainers',
          fields: 'trainer_id, user_id, birthday_date, specialization',
          where: {'user_id': userId},
        ),
        db.getOne(
          table: 'trainees',
          fields: 'trainee_id, user_id, birthday_date',
          where: {'user_id': userId},
        ),
      ]);

      if (results[0].isNotEmpty) {
        mergedUser.addAll(Map<String, dynamic>.from(results[0]));
        return Result.success(OutputTrainerDao.fromJson(mergedUser));
      } else if (results[1].isNotEmpty) {
        mergedUser.addAll(Map<String, dynamic>.from(results[1]));
        return Result.success(OutputTraineeDao.fromJson(mergedUser));
      }

      return Result.success(UserSigninDao.fromJson(mergedUser));
    } catch (e) {
      return Result.failure(
        AppError(AppErrorType.internal, "Database Error during sign-in: $e"),
      );
    } finally {
      await db?.close();
    }*/
  }

  @override
  Future<Result<Map<String, dynamic>>> signinWithSocials(
    SigninSocialDto dto,
  ) async {
    final authResult = await _remoteUserService.signInUserWithSocials(dto);
    if (authResult.isFailure) return Result.failure(authResult.error!);

    return Result.success(authResult.data!);
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
  Future<Result<bool>> linkSocial(UserLinkAccountDto dto) async {
    return await _remoteUserService.linkSocial(dto);
  }

  @override
  Future<Result<OutputUserDao>> getSession(String sessionCookie) async {
    final result = await _remoteUserService.getSession(sessionCookie);

    return result;
  }
}
