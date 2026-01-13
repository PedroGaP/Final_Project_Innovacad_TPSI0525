import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:innovacad_api/src/api/utils/json_utils.dart';
import 'package:vaden/vaden.dart';

@Component()
class LoggerMiddleware extends VadenMiddleware {
  Map<String, String> headers = {'Content-Type': 'application/json'};
  Map<String, dynamic> defaultResponseBody = {"code": "", "data": ""};

  @override
  FutureOr<Response> handler(Request request, Handler handler) async {
    try {
      final response = await handler(request);
      final String responseBody = await response.readAsString();

      final dynamic decoded = JsonUtils.tryDecode(responseBody);
      final bool isJson = decoded != null;

      print(response.statusCode);

      switch (response.statusCode) {
        case HttpStatus.badRequest:
          return handleBadRequest(responseBody);
        case HttpStatus.ok:
          return handleOk(isJson, decoded, responseBody);
        case HttpStatus.unauthorized:
          return handleUnauthorized();
        default:
          return handleNotFound();
      }
    } catch (e, stack) {
      return handleInternalServerError(e, stack);
    }
  }

  Response handleInternalServerError(e, stack) {
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      defaultResponseBody,
    );

    body['code'] = 'internal_server_error';
    body['data'] = 'An error occurred while handling your request.';
    body['error'] = e.toString();
    body['stackTrace'] = stack.toString();

    return Response.internalServerError(body: body, headers: headers);
  }

  Response handleOk(isJson, decoded, responseBody) {
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      defaultResponseBody,
    );

    body['code'] = isJson
        ? (decoded is List
              ? (decoded.isEmpty ? "data_not_found" : "data_found")
              : (decoded is Map && decoded.isEmpty
                    ? "data_not_found"
                    : "data_found"))
        : (responseBody.trim().isEmpty ? "empty_response" : "success_response");
    body['data'] = isJson ? decoded : responseBody;

    final String encoded = jsonEncode(body);
    return Response.ok(encoded, headers: {'Content-Type': 'application/json'});
  }

  Response handleBadRequest(String responseBody) {
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      defaultResponseBody,
    );

    body['code'] = "bad_request";
    body['data'] =
        "There is missing fields or an UUID is invalid! Check the request and try again!";
    body.addAll(jsonDecode(responseBody));

    return Response.badRequest(body: jsonEncode(body), headers: headers);
  }

  Response handleUnauthorized() {
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      defaultResponseBody,
    );

    body['code'] = 'unauthorized_request';
    body['data'] = "The request was unauthorized, try again later.";
    return Response.unauthorized(jsonEncode(body), headers: headers);
  }

  Response handleNotFound() {
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      defaultResponseBody,
    );

    body['code'] = 'not_found';
    body['data'] = "The request you made was not found.";
    return Response.notFound(jsonEncode(body), headers: headers);
  }
}
