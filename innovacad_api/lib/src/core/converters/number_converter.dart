import 'package:json_annotation/json_annotation.dart';

class NumberConverter implements JsonConverter<int, Object> {
  const NumberConverter();

  @override
  int fromJson(Object json) {
    if (json is num) return int.parse(json.toString());
    if (json is int) return json;
    if (json is String) return int.parse(json);
    if (json is bool) return json ? 1 : 0;

    throw ArgumentError(
      'Expected String, int, num or bool, got ${json.runtimeType}',
    );
  }

  @override
  Object toJson(int object) {
    return object;
  }
}

const booleanConverter = NumberConverter();
