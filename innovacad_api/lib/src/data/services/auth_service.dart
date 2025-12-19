import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthService extends JwtService {
  AuthService({
    required super.secret,
    super.tokenValidity = const Duration(hours: 2),
    super.refreshTokenValidity = const Duration(days: 30),
    super.issuer = 'vaden',
    super.audiences = const [],
  });

  factory AuthService.withSettings(ApplicationSettings settings) {
    return AuthService(
      secret: settings['security']['secret'],
      tokenValidity: Duration(seconds: settings['security']['tokenValidity']),
      refreshTokenValidity: Duration(
        seconds: settings['security']['refreshTokenValidity'],
      ),
      issuer: settings['security']['issuer'],
      audiences: settings['security']['audiences'].cast<String>(),
    );
  }

  @override
  Map<String, dynamic>? verifyToken(String token) {
    String cleaned = token.trim().replaceAll('"', '');

    if (cleaned.toLowerCase().startsWith('bearer ')) {
      cleaned = cleaned.substring(7).trim();
    }
    cleaned = cleaned
        .replaceAll('=', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\.\-_]'), '');

    try {
      final jwt = JWT.verify(
        cleaned,
        SecretKey(secret),
        checkHeaderType: false,
      );

      final payload = jwt.payload as Map<String, dynamic>;
      final session = payload['session'] as Map<String, dynamic>?;

      if (session == null) throw JWTInvalidException('Missing session object');

      if (session['iss'] != issuer) {
        throw JWTInvalidException(
          'invalid issuer: expected $issuer, got ${session['iss']}',
        );
      }

      if (!audiences.contains(session['aud'])) {
        throw JWTInvalidException(
          'invalid audience: expected $audiences, got ${session['aud']}',
        );
      }

      return {
        ...payload,
        'id': payload['user']?['id'] ?? session['userId'],
        'sub': session['userId'],
      };
    } catch (_) {
      return null;
    }
  }
}
