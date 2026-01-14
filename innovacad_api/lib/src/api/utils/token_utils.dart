class TokenUtils {
  static String? getUserToken(String cookie) {
    final regexp = RegExp(
      '(?<=better-auth\.session_data=)(?<header>[^.]+)\.(?<payload>[^.]+)\.(?<signature>[^;]+)',
    );
    final parsedToken = regexp.firstMatch(cookie);

    if (parsedToken == null) return null;

    return parsedToken.group(0);
  }
}
