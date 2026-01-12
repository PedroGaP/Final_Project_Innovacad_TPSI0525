import 'dart:convert';

import 'package:innovacad_api/config/redis/redis_configuration.dart';
import 'package:vaden/vaden.dart';

@Component()
class RedisUtils {
  final _cmd = RedisConfiguration.cmd;

  RedisUtils();

  Future<dynamic> getOrSetCache(
    String key,
    Future<dynamic> Function() cb,
  ) async {
    try {
      if (_cmd == null)
        throw Exception("Redis Command is null, connection failed ?");

      final dynamic result = await _cmd.get(key);

      if (result != null) {
        try {
          return jsonDecode(result);
        } catch (_) {
          return result;
        }
      }

      final dynamic newData = await cb();

      final newDataEncoded = jsonEncode(newData);

      final newDataResult = await _cmd.send_object([
        "SETEX",
        key,
        "30",
        newDataEncoded,
      ]);

      if (newDataResult == "OK") return newData;

      throw Exception("Redis returned an invalid result !");
    } catch (e, s) {
      print("[ERROR]: $e\n[STACK]: $s");
      return null;
    }
  }
}
