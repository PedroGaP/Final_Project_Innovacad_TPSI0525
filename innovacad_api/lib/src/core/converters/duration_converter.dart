import 'package:json_annotation/json_annotation.dart';

class DurationConverter implements JsonConverter<Duration, Object> {
  final bool? preserve;
  const DurationConverter([this.preserve = false]);

  @override
  Duration fromJson(Object json) {
    if (json is Duration) return json;

    if (json is int) {
      return Duration(minutes: json);
    }

    if (json is String) {
      final parsedInt = int.tryParse(json);
      if (parsedInt != null) {
        return Duration(minutes: parsedInt);
      }

      return _parseDurationString(json);
    }

    throw ArgumentError(
      'Expected String, int, or Duration, got ${json.runtimeType}',
    );
  }

  Duration _parseDurationString(String s) {
    final parts = s.split(':');

    if (parts.length >= 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;

      return Duration(hours: hours, minutes: minutes);
    }

    throw FormatException(
      "Invalid duration format: $s. Expected HH:mm or HH:mm:ss",
    );
  }

  @override
  Object toJson(Duration object) {
    if (preserve ?? false) return object;

    return "${object.inHours.toString().padLeft(2, '0')}:${(object.inMinutes % 60).toString().padLeft(2, '0')}";
  }
}

const durationConverter = DurationConverter();
const durationPreserveConverter = DurationConverter(true);
