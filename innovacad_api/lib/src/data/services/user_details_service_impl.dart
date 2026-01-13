import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@Service()
class UserDetailsServiceImpl implements UserDetailsService {
  final String table = 'user';

  @override
  Future<UserDetails?> loadUserByUsername(String userId) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final user = (await db.getOne(
        table: table,
        where: {'id': userId},
      )).cast<String, dynamic>();

      if (user.isEmpty) return null;

      return UserDetails(
        username: user["username"],
        password: "",
        roles: [user["role"]],
      );
    } catch (e, s) {
      print(e);
      print(s);
    }

    return null;
  }
}
