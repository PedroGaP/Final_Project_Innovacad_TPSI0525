import 'package:vaden/vaden.dart';

Middleware corsMiddleware({
  List<String> allowedOrigins = const ['http://localhost:5000'],
  List<String> allowMethods = const ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  List<String> allowHeaders = const [
    'Origin',
    'Content-Type',
    'Accept',
    'Authorization',
    'Cookie',
    'better-auth.session_data',
  ],
}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final requestOrigin = request.headers['Origin'];

      String? allowOriginHeader;
      if (allowedOrigins.contains('*')) {
        allowOriginHeader = '*';
      } else if (requestOrigin != null &&
          allowedOrigins.contains(requestOrigin)) {
        allowOriginHeader = requestOrigin;
      }

      if (request.method.toUpperCase() == 'OPTIONS') {
        var headers = <String, String>{
          if (allowOriginHeader != null)
            'Access-Control-Allow-Origin': allowOriginHeader,
          'Access-Control-Allow-Methods': allowMethods.join(', '),
          'Access-Control-Allow-Headers': allowHeaders.join(', '),
          'Access-Control-Allow-Credentials': 'true',
        };
        return Response.ok('', headers: headers);
      }

      final response = await innerHandler(request);

      var headers = <String, String>{
        if (allowOriginHeader != null)
          'Access-Control-Allow-Origin': allowOriginHeader,
        'Access-Control-Allow-Methods': allowMethods.join(', '),
        'Access-Control-Allow-Headers': allowHeaders.join(', '),
        'Access-Control-Allow-Credentials': 'true',
      };
      return response.change(headers: headers);
    };
  };
}
