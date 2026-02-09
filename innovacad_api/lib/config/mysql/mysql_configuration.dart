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

  static Future<MysqlUtils> getConnection() async {
    if (utils == null) {
      throw Exception('Database not initialized. Call initDatabase() first.');
    }

    if (!(await utils!.isConnectionAlive())) {
      print('⚠️ Connection pool is dead, attempting to reconnect...');
      utils = MysqlUtils(
        settings: settings!,
        errorLog: (log) => print(log),
        sqlLog: (log) => print(log),
        connectInit: (log) => print(log),
      );
    }

    return utils!;
  }

  static Future<void> closeConnection(MysqlUtils? db) async {
    //if (db != null && (await db.isConnectionAlive())) {
    //  db.close();
    //}
  }

  static Future<T> executeWithConnection<T>(
    Future<T> Function(MysqlUtils db) operation,
  ) async {
    final db = await getConnection();
    try {
      return await operation(db);
    } finally {
      await closeConnection(db);
    }
  }

  @Bean()
  Future<MysqlUtils> initDatabase(ApplicationSettings settings) async {
    if (utils != null && (await utils!.isConnectionAlive())) {
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
      maxConnections: 10,
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
