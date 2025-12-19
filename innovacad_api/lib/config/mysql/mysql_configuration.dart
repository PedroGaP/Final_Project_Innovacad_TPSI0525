import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Configuration()
class MysqlConfiguration {
  Future<MysqlUtils> getDatabase(ApplicationSettings settings) async {
    return MysqlUtils(
      settings: MysqlUtilsSettings(
        host: settings["mysql"]["hostname"],
        user: settings["mysql"]["username"],
        db: settings["mysql"]["database"],
        password: settings["mysql"]["password"],
        secure: true,
        pool: true,
        collation: "utf8mb4_uca1400_ai_ci",
      ),
      errorLog: (log) {
        print(log);
      },
      sqlLog: (log) {
        print(log);
      },
      connectInit: (log) {
        print(log);
      },
    );
  }
}
