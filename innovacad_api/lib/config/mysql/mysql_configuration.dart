import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Configuration()
class MysqlConfiguration {
  static MysqlUtils? utils;
  static MysqlUtilsSettings? settings;

  MysqlConfiguration();

  static Future<MysqlUtils> connect() async {
    return utils!;
  }

  @Bean()
  Future<MysqlUtils> initDatabase(ApplicationSettings settings) async {
    if (utils != null && !(await utils!.isConnectionAlive())) {
      return utils!;
    }

    MysqlConfiguration.settings = MysqlUtilsSettings(
      host: settings["mysql"]["hostname"],
      user: settings["mysql"]["username"],
      db: settings["mysql"]["database"],
      password: settings["mysql"]["password"],
      secure: true,
      pool: true,
      collation: "utf8mb4_uca1400_ai_ci",
    );

    utils = MysqlUtils(
      settings: MysqlConfiguration.settings!,
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

    return utils!;
  }
}
