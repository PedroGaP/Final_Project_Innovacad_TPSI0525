class Result<T> {
  final T? data;
  final AppError? error;
  final Map<String, dynamic>? headers;

  const Result._({this.data, this.error, this.headers});

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  static Result<T> success<T>(T data, {Map<String, dynamic>? headers}) =>
      Result._(data: data, headers: headers);

  static Result<T> failure<T>(
    AppError error, {
    Map<String, dynamic>? headers,
  }) => Result._(error: error, headers: headers);
}

class AppError {
  final AppErrorType type;
  final String message;
  final Map<String, dynamic>? details;

  AppError(this.type, this.message, {this.details});

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'message': message,
    if (details != null) 'details': details,
  };
}

enum AppErrorType {
  notFound,
  validation,
  conflict,
  unauthorized,
  forbidden,
  badRequest,
  external,
  internal,
}
