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

      if (user.isEmpty) {
        await db.close();
        return null;
      }

      final details = UserDetails(
        username: user["username"],
        password: "", // Password not needed for simple verification if token is trusted
        roles: [user["role"]],
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
