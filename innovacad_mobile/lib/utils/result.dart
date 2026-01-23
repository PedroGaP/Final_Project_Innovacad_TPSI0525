class AppError {
  final String message;
  final Map<String, dynamic>? details;

  AppError({required this.message, this.details});
}

class Result<T> {
  final T? value;
  final AppError? error;

  bool get isSuccess => error == null;
  bool get isFailure => !isSuccess;

  Result({this.value, this.error});

  factory Result.failure(AppError error) => Result(error: error);
  factory Result.success(T value) => Result(value: value);
}
