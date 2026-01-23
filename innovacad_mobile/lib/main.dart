import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:innovacad_mobile/service/sign_service.dart';
import 'package:innovacad_mobile/utils/router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final theme = FThemes.blue.light;

  return runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SignService())],
      child: MaterialApp.router(
        supportedLocales: FLocalizations.supportedLocales,
        theme: theme.toApproximateMaterialTheme(),
        localizationsDelegates: const [
          ...FLocalizations.localizationsDelegates,
        ],
        builder: (_, child) => FAnimatedTheme(
          data: theme,
          child: FToaster(child: child!),
        ),
        debugShowCheckedModeBanner: false,
        title: "Innovacad",
        routerConfig: AppRouter.router,
      ),
    ),
  );
}
