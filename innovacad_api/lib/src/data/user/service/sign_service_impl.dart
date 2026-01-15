import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart' as v;

abstract class ISignService {
  Future<Result<Map<String, dynamic>>> signin(UserSigninDto dto);
}

@v.Service()
class SignServiceImpl implements ISignService {
  final RemoteUserService _remoteUserService;

  SignServiceImpl(this._remoteUserService);

  @override
  Future<Result<Map<String, dynamic>>> signin(UserSigninDto dto) async {
    final authResult = await _remoteUserService.signInUser(dto);
    if (authResult.isFailure) return Result.failure(authResult.error!);

    final Map<String, dynamic> mergedUser = authResult.data!;

    final userId = mergedUser["id"];
    final role = mergedUser["role"]?.toString().toLowerCase();

    if (role == 'admin') return Result.success(mergedUser);

    MysqlUtils? db;
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
      } else if (results[1].isNotEmpty) {
        mergedUser.addAll(Map<String, dynamic>.from(results[1]));
      }

      return Result.success(mergedUser);
    } catch (e) {
      return Result.failure(
        AppError(AppErrorType.internal, "Database Error during sign-in: $e"),
      );
    } finally {
      await db?.close();
    }
  }
}
