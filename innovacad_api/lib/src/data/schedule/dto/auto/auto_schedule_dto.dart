import 'package:innovacad_api/src/core/core.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:vaden/vaden.dart' as vaden;

@annotation.JsonSerializable()
@vaden.DTO()
class AutoScheduleDto {
  @annotation.JsonKey(name: 'class_id')
  @vaden.JsonKey('class_id')
  final String classId;

  @annotation.JsonKey(name: 'start_date')
  @vaden.JsonKey('start_date')
  @DateTimeConverter()
  final DateTime startDate;

  @annotation.JsonKey(name: 'regime_type')
  @vaden.JsonKey('regime_type')
  final int regimeType;

  @annotation.JsonKey(name: 'is_online')
  @vaden.JsonKey('is_online')
  final bool isOnline;

  AutoScheduleDto({
    required this.classId,
    required this.startDate,
    required this.regimeType,
    required this.isOnline,
  });
}
