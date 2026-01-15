import 'dart:convert';

import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';

Response resultToResponse<T>(Result<T> result) {
  if (result.isSuccess) {
    final body = result.data;
    if (body is Response) return body;

    final encoded = jsonEncode(body);

    return Response.ok(encoded, headers: {'Content-Type': 'application/json'});
  }

  final err = result.error!;
  final status = _statusFromErrorType(err.type);
  return Response(
    status,
    body: jsonEncode({'error': err.toJson()}),
    headers: {'Content-Type': 'application/json'},
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
