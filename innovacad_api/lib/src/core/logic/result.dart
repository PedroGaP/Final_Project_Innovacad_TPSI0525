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

class AppError {
  final AppErrorType type;
  final String message;
  final Map<String, dynamic>? details;

  AppError(this.type, this.message, {this.details});

  String get typeName => type.toString().split('.').last;

  Map<String, dynamic> toJson() => {
    'type': typeName,
    'message': message,
    if (details != null) 'details': details,
  };
}

class Result<T> {
  final T? _data;
  final AppError? _error;

  final String? _successMessage;
  final String? _successCode;

  final Map<String, dynamic>? headers;

  const Result._({
    T? data,
    AppError? error,
    this.headers,
    String? successMessage,
    String? successCode,
  }) : _data = data,
       _error = error,
       _successMessage = successMessage,
       _successCode = successCode;

  bool get isSuccess => _error == null;
  bool get isFailure => _error != null;

  T? get data => _data;
  AppError? get error => _error;

  static Result<T> success<T>(
    T data, {
    Map<String, dynamic>? headers,
    String message = 'Success',
    String code = 'ok',
  }) => Result._(
    data: data,
    headers: headers,
    successMessage: message,
    successCode: code,
  );

  static Result<T> failure<T>(
    AppError error, {
    Map<String, dynamic>? headers,
  }) => Result._(error: error, headers: headers);

  Map<String, dynamic> toJson() {
    if (isFailure) {
      return {
        'is_error': true,
        'code': error!.typeName,
        'message': error!.message,
        'data': error!.details ?? {},
      };
    } else {
      return {
        'is_error': false,
        'code': _successCode,
        'message': _successMessage,
        'data': _data,
      };
    }
  }
}
