class Result<T> {
  final T? data;
  final AppError? error;

  const Result._({this.data, this.error});

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  static Result<T> success<T>(T data) => Result._(data: data);

  static Result<T> failure<T>(AppError error) => Result._(error: error);
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
