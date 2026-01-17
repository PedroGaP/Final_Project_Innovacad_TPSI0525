import 'package:vaden/vaden.dart';

final _corsHeaders = {
  'Access-Control-Allow-Origin': 'http://localhost:5000',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Headers':
      'Origin, Content-Type, Authorization, Cookie, X-Requested-With',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
};

// Cria um middleware para lidar com o OPTIONS
/*Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // 1. Se for um pedido OPTIONS, responde logo OK com os headers
      print("aaa");
      if (request.method == 'OPTIONS') {
        print("aaa");
        return Response.ok('', headers: _corsHeaders);
      }

      // 2. Processa o pedido normal
      final response = await innerHandler(request);

      // 3. Garante que a resposta final tem os headers (segurança extra)
      return response.change(headers: _corsHeaders);
    };
  };
}*/

Middleware corsMiddleware({
  List<String> allowedOrigins = const ['http://localhost:5000'],
  List<String> allowMethods = const ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  List<String> allowHeaders = const [
    'Origin',
    'Content-Type',
    'Accept',
    'Authorization',
  ],
}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final requestOrigin = request.headers['Origin'];

      print("aaaaaaa");

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
