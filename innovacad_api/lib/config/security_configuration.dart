import 'package:innovacad_api/src/core/auth/auth_service.dart';
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
      RequestMatcher('/auth/**').denyAll(),
      RequestMatcher('/docs/**').permitAll(),
      RequestMatcher('/sign/**').permitAll(),
      RequestMatcher('/email/**').permitAll(),
      RequestMatcher('/statistics/**').permitAll(),

      // Trainees
      RequestMatcher(
        '/trainees/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/trainees/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/trainees/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher('/trainees/**', HttpMethod.get).authenticated(),

      // Trainers
      RequestMatcher(
        '/trainers/*',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'assistant', 'trainer', 'coordinator']),
      RequestMatcher(
        '/trainers/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/trainers/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/trainers/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher('/trainers/**', HttpMethod.get).authenticated(),

      // Classes
      RequestMatcher(
        '/classes/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'assistant', 'coordinator']),
      RequestMatcher(
        '/classes/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'assistant', 'coordinator']),
      RequestMatcher(
        '/classes/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'assistant', 'coordinator']),
      RequestMatcher('/classes/**', HttpMethod.get).authenticated(),

      // Modules
      RequestMatcher(
        '/modules/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/modules/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/modules/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher('/modules/**', HttpMethod.get).authenticated(),

      // Grades
      RequestMatcher(
        '/grades/finalize/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'coordinator']),
      RequestMatcher(
        '/grades/batch',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'trainer', 'coordinator']),
      RequestMatcher(
        '/grades/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'trainer', 'coordinator']),
      RequestMatcher(
        '/grades/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'trainer', 'coordinator']),
      RequestMatcher(
        '/grades/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'trainer', 'coordinator']),
      RequestMatcher(
        '/grades/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'trainer', 'coordinator']),
      RequestMatcher('/grades/**', HttpMethod.get).authenticated(),

      // ClassModules
      RequestMatcher(
        '/class-modules/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'coordinator', 'assistant']),
      RequestMatcher(
        '/class-modules/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'coordinator', 'assistant']),
      RequestMatcher(
        '/class-modules/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'coordinator', 'assistant']),
      RequestMatcher('/class-modules/**', HttpMethod.get).authenticated(),

      // Schedules
      RequestMatcher('/schedules/**', HttpMethod.get).authenticated(),
      RequestMatcher(
        '/schedules/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'coordinator']),
      RequestMatcher(
        '/schedules/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'coordinator']),
      RequestMatcher(
        '/schedules/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'coordinator']),

      // Summaries
      RequestMatcher('/summaries/**', HttpMethod.get).authenticated(),
      RequestMatcher(
        '/summaries/**',
        HttpMethod.post,
      ).hasAnyRole(['admin', 'trainer', 'coordinator']),
      RequestMatcher(
        '/summaries/**',
        HttpMethod.put,
      ).hasAnyRole(['admin', 'trainer', 'coordinator']),

      // Rooms
      RequestMatcher('/rooms/**', HttpMethod.get).authenticated(),
      RequestMatcher(
        '/rooms/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/rooms/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/rooms/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'assistant']),

      // Availabilities
      RequestMatcher('/availabilities/**', HttpMethod.get).authenticated(),
      RequestMatcher(
        '/availabilities/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'coordinator', 'trainer']),
      RequestMatcher(
        '/availabilities/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'coordinator', 'trainer']),
      RequestMatcher(
        '/availabilities/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'coordinator', 'trainer']),

      // Courses
      RequestMatcher('/courses/**', HttpMethod.get).permitAll(),
      RequestMatcher(
        '/courses/**',
        HttpMethod.post,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/courses/**',
        HttpMethod.put,
      ).hasAnyRole(["admin", 'assistant']),
      RequestMatcher(
        '/courses/**',
        HttpMethod.delete,
      ).hasAnyRole(["admin", 'assistant']),

      // Documents
      RequestMatcher('/documents/**', HttpMethod.get).authenticated(),
      RequestMatcher('/documents/**', HttpMethod.post).authenticated(),
      RequestMatcher('/documents/**', HttpMethod.delete).authenticated(),

      // Enrollments
      RequestMatcher('/enrollments/**', HttpMethod.get).authenticated(),
      RequestMatcher(
        '/enrollments/**',
        HttpMethod.put,
      ).hasAnyRole(['admin', 'assistant']),
      RequestMatcher(
        '/enrollments/**',
        HttpMethod.post,
      ).hasAnyRole(['admin', 'assistant']),
      RequestMatcher(
        '/enrollments/**',
        HttpMethod.delete,
      ).hasAnyRole(['admin', 'assistant']),

      AnyRequest().permitAll(),
    ]);
  }
}
