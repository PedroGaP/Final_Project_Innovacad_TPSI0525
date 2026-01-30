import 'dart:io';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/middleware/cors_middleware.dart';
import 'package:innovacad_api/vaden_application.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:vaden/vaden.dart';
import 'package:shelf/shelf_io.dart' as io;

Future<void> main(List<String> args) async {
  final vaden = VadenApp();

  vaden.injector.add(MysqlConfiguration.new);

  await vaden.setup();

  final staticHandler = createStaticHandler(
    'public',
    defaultDocument: 'index.html',
    listDirectories: true,
  );

  final staticHandlerWithCors = Pipeline()
      .addMiddleware(corsMiddleware())
      .addHandler(staticHandler);

  final apiHandler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addVadenMiddleware(EnforceJsonContentType())
      .addMiddleware(logRequests())
      .addHandler(vaden.router.call);

  final finalHandler = Cascade()
      .add(staticHandlerWithCors)
      .add(apiHandler)
      .handler;

  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  final server = await io.serve(finalHandler, InternetAddress.anyIPv4, port);

  print('--- InnovAcad API Server ---');
  print('Server is running on port ${server.address.address}:${server.port}');
  print('----------------------------');
}
