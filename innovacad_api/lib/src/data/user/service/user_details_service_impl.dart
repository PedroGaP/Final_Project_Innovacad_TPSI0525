import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

class ExtendedUserDetails extends UserDetails {
  final String? token;

  ExtendedUserDetails({
    this.token,
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
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final user = (await db.getOne(
        table: table,
        where: {'id': userId},
      )).cast<String, dynamic>();

      if (user.isEmpty) {
        await db.close();
        return null;
      }

      final details = ExtendedUserDetails(
        username: user["username"],
        password: "",
        roles: [user["role"]],
        token: "",
      );

      await db.close();
      return details;
    } catch (e, s) {
      if (db != null) await db.close();
      print(e);
      print(s);
    }

    return null;
  }
}
