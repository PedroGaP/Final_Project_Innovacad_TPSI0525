import 'package:go_router/go_router.dart';
import 'package:innovacad_mobile/views/auth/sign_in_view.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/sign-in',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/sign-in', builder: (context, state) => SignInView()),
    ],
  );

  static GoRouter get router => _router;
}
