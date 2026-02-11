import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

class ExtendedUserDetails extends UserDetails {
  final String? token;
  final String id;
  final String? trainerId;
  final String? traineeId;

  ExtendedUserDetails({
    this.token,
    this.trainerId,
    this.traineeId,
    required this.id,
    required super.username,
    required super.password,
    required super.roles,
  });
}

@Service()
class UserDetailsServiceImpl implements UserDetailsService {
  final String table = 'user';

  @override
  Future<ExtendedUserDetails?> loadUserByUsername(String userId) async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final user = (await db.getOne(
          table: table,
          where: {'id': userId},
        )).cast<String, dynamic>();

        if (user.isEmpty) {
          return null;
        }

        String? trainerId;
        String? traineeId;
        final String role = user["role"];

        if (['trainer', 'coordinator'].contains(role)) {
          final trainerData = await db.getOne(
            table: 'trainers',
            where: {'user_id': user['id']},
          );

          if (trainerData.isNotEmpty) {
            trainerId = trainerData['trainer_id']?.toString();
          }
        } else if (role == 'trainee') {
          final traineeData = await db.getOne(
            table: 'trainees',
            where: {'user_id': user['id']},
          );

          if (traineeData.isNotEmpty) {
            traineeId = traineeData['trainee_id']?.toString();
          }
        }

        final details = ExtendedUserDetails(
          id: user["id"],
          username: user["username"],
          password: "",
          roles: [role],
          token: "",
          trainerId: trainerId,
          traineeId: traineeId,
        );

        return details;
      });
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }
}
