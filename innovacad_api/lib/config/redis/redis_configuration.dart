import 'package:redis/redis.dart';
import 'package:vaden/vaden.dart';

@Configuration()
class RedisConfiguration {
  final connection = RedisConnection();
  static Command? cmd;

  @Bean()
  Future init(ApplicationSettings settings) async {
    try {
      final host = settings['redis']['host'];
      final port = settings['redis']['port'];

      cmd = await connection.connect(host, port);
    } catch (e) {
      print(e);
    }
  }
}
