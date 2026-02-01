import 'dart:io';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/middleware/cors_middleware.dart';
import 'package:innovacad_api/vaden_application.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:vaden/vaden.dart';
import 'package:shelf/shelf_io.dart' as io;

Middleware errorHandlingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e, s) {
        print('🔥 CRITICAL SERVER ERROR: $e');
        print(s);

        return Response.internalServerError(
          body:
              '{"error": "Internal Server Error", "details": "${e.toString().replaceAll('"', "'")}"}',
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}

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
      .addMiddleware(errorHandlingMiddleware())
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
