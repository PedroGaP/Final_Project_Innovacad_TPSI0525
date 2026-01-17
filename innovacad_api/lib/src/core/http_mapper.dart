import 'dart:convert';

import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';

const _corsHeaders = {
  'Access-Control-Allow-Origin': 'http://localhost:5000',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Headers':
      'Origin, Content-Type, Authorization, Cookie, X-Requested-With',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
};

Response resultToResponse<T>(
  Result<T> result, {
  Map<String, dynamic>? headers,
}) {
  final finalHeaders = <String, Object>{
    'Content-Type': 'application/json',
    ..._corsHeaders,
    if (headers != null) ...headers,
  }.cast<String, Object>();

  if (result.isSuccess) {
    final body = result.data;
    print(body);
    print(body.runtimeType);

    if (body is Response) {
      return body.change(headers: finalHeaders);
    }

    final encoded = jsonEncode(body);

    if (headers != null) {
      print("entrou com headers extra");
    }

    return Response.ok(encoded, headers: finalHeaders);
  }

  final err = result.error!;
  final status = _statusFromErrorType(err.type);

  return Response(
    status,
    body: jsonEncode({'error': err.toJson()}),
    headers: finalHeaders,
  );
}

int _statusFromErrorType(AppErrorType type) {
  switch (type) {
    case AppErrorType.notFound:
      return 404;
    case AppErrorType.validation:
    case AppErrorType.badRequest:
      return 400;
    case AppErrorType.conflict:
      return 409;
    case AppErrorType.unauthorized:
      return 401;
    case AppErrorType.forbidden:
      return 403;
    case AppErrorType.external:
      return 502;
    case AppErrorType.internal:
      return 500;
  }
}
