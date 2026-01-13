import 'dart:convert';

class JsonUtils {
  static String? tryEncode(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return null;
    }
  }

  static dynamic tryDecode(String data) {
    try {
      return jsonDecode(data);
    } catch (_) {
      return null;
    }
  }

  static bool isEncodable(dynamic data) {
    try {
      jsonEncode(data);
      return true;
    } catch (_) {
      return false;
    }
  }
}
