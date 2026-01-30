import 'package:json_annotation/json_annotation.dart';

class DoubleConverter implements JsonConverter<double, Object> {
  const DoubleConverter();

  @override
  double fromJson(Object json) {
    if (json is num) return double.parse(json.toString());
    if (json is double) return json;
    if (json is String) return double.parse(json);
    if (json is int) return double.parse(json.toString());

    throw ArgumentError(
      'Expected String, double, num or int, got ${json.runtimeType}',
    );
  }

  @override
  Object toJson(double object) {
    return object;
  }
}

const doubleConverter = const DoubleConverter();
