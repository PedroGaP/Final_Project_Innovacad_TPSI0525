import 'dart:convert';

import 'package:vaden/vaden.dart';

class LoomColors {
  static const reset = "\x1B[0m";
  static const bgLBlue = "\x1B[104m";
  static const bgLRed = "\x1B[101m";
  static const bgLYellow = "\x1B[103m";
  static const bgLGreen = "\x1B[102m";
  static const bgGreen = "\x1B[42m";
  static const bgYellow = "\x1B[43m";

  static const title = '$reset$bgLBlue INNOVACAD $reset';
  static const error = '$reset$bgLRed ERROR $reset';
  static const missing = '$reset$bgYellow MISSING $reset';
}

Middleware loomLogger() => (innerHandler) {
  DateTime startTime = DateTime.now();
  Stopwatch watch = Stopwatch()..start();

  return (request) {
    print(
      '\n${LoomColors.title} Starting request to ${request.requestedUri.path}',
    );
    return Future.sync(() => innerHandler(request))
        .then((Response response) {
          try {
            watch.stop();
            var message =
                '${LoomColors.title} ${startTime.toIso8601String()} ${watch.elapsed.toString()} ${_buildMethod(request.method, response.statusCode)} ${request.requestedUri.path}';

            print(message);

            return response;
          } catch (e, s) {
            print(e);
            print(s);
            return Response.internalServerError(
              body: jsonEncode({
                'message': 'Internal server error',
                'error': e.toString(),
                'stack': s.toString(),
              }),
            );
          }
        })
        .onError((exception, stackTrace) {
          throw exception ?? "Not valid.";
        });
  };
};

String _buildMethod(String method, int statusCode) {
  switch (method) {
    case 'GET':
      return '${LoomColors.reset}${LoomColors.bgLBlue} GET ($statusCode) ${LoomColors.reset}';
    case 'POST':
      return '${LoomColors.reset}${LoomColors.bgGreen} POST ($statusCode) ${LoomColors.reset}';
    case 'PUT':
      return '${LoomColors.reset}${LoomColors.bgYellow} PUT ($statusCode) ${LoomColors.reset}';
    case 'DELETE':
      return '${LoomColors.reset}${LoomColors.bgLRed} DELETE ($statusCode) ${LoomColors.reset}';
  }
  return '';
}
