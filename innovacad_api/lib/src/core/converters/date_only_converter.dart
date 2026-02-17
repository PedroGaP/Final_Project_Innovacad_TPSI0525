import 'package:json_annotation/json_annotation.dart';

class DateOnlyConverter implements JsonConverter<DateTime, Object> {
  const DateOnlyConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is DateTime) return json;

    if (json is String) {
      if (json.contains('T')) {
         return DateTime.parse(json);
      }
      return DateTime.parse(json + "T00:00:00");
    }

    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);

    throw ArgumentError(
      'Expected String, int, or DateTime, got ${json.runtimeType}',
    );
  }

  @override
  Object toJson(DateTime object) {
    final year = object.year.toString().padLeft(4, '0');
    final month = object.month.toString().padLeft(2, '0');
    final day = object.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }
}

const dateOnlyConverter = const DateOnlyConverter();
