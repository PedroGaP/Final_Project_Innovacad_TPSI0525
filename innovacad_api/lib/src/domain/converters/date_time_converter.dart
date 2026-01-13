import 'package:json_annotation/json_annotation.dart';

class DateTimeConverter implements JsonConverter<DateTime, Object> {
  final bool? preserve;
  const DateTimeConverter([this.preserve = false]);

  @override
  DateTime fromJson(Object json) {
    if (json is DateTime) return json;
    if (json is String)
      return DateTime.fromMillisecondsSinceEpoch(int.parse(json));

    throw ArgumentError('Expected String or DateTime, got ${json.runtimeType}');
  }

  @override
  Object toJson(DateTime object) {
    if (preserve ?? false) return object;
    return object.millisecondsSinceEpoch.toString();
  }
}

const dateTimeConverter = const DateTimeConverter();
const dateTimePreserveConverter = const DateTimeConverter(true);
