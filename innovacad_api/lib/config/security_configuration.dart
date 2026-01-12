import 'package:innovacad_api/src/data/services/auth_service.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@Configuration()
class SecurityConfiguration {
  @Bean()
  JwtService jwtService(ApplicationSettings settings) {
    return AuthService.withSettings(settings);
  }

  @Bean()
  HttpSecurity httpSecurity() {
    return HttpSecurity([
      RequestMatcher('/auth/**').permitAll(),
      RequestMatcher('/docs/**').permitAll(),
      RequestMatcher('/courses/**').authenticated(),
      AnyRequest().permitAll(),
    ]);
  }
}
