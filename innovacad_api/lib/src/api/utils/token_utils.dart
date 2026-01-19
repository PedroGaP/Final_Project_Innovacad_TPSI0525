class TokenUtils {
  static String? getUserToken(String cookie) {
    final regexp = RegExp(
      '(?<=better-auth\.session_data=)(?<header>[^.]+)\.(?<payload>[^.]+)\.(?<signature>[^;]+)',
    );
    final parsedToken = regexp.firstMatch(cookie);

    if (parsedToken == null) return null;

    return parsedToken.group(0);
  }

  static String? getUserSessionToken(String cookie) {
    final regexp = RegExp('(?<=better-auth\.session_token=)([^;]+)');
    final parsedToken = regexp.firstMatch(cookie);

    if (parsedToken == null) return null;

    return parsedToken.group(0);
  }

  static String? getUserSessionData(String cookie) {
    final regexp = RegExp('(?<=better-auth\.session_data=)([^;]+)');
    final parsedToken = regexp.firstMatch(cookie);

    if (parsedToken == null) return null;

    return parsedToken.group(0);
  }
}
