import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_public_schedule_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputPublicScheduleDao {
  @annotation.JsonKey(name: 'regime_type')
  final String? regimeType;

  @annotation.JsonKey(name: 'module_name')
  final String? moduleName;

  @annotation.JsonKey(name: 'trainer_name')
  final String? trainerName;

  @annotation.JsonKey(name: 'trainer_email')
  final String? trainerEmail;

  @annotation.JsonKey(name: 'date_day')
  @DateTimeConverter()
  final DateTime? dateDay;

  @annotation.JsonKey(name: 'start_time')
  @DurationConverter()
  final Duration? startTime;

  @annotation.JsonKey(name: 'end_time')
  @DurationConverter()
  final Duration? endTime;

  @annotation.JsonKey(name: 'is_online')
  final bool? isOnline;

  @annotation.JsonKey(name: 'room_name')
  final String? roomName;

  @annotation.JsonKey(name: 'start')
  final String? start;

  @annotation.JsonKey(name: 'end')
  final String? end;

  @annotation.JsonKey(name: 'class_name')
  final String? className;

  @annotation.JsonKey(name: 'current_duration')
  final double? currentDuration;

  @annotation.JsonKey(name: 'total_duration')
  final double? totalDuration;

  OutputPublicScheduleDao({
    this.moduleName,
    this.trainerName,
    this.startTime,
    this.endTime,
    this.isOnline,
    this.dateDay,
    this.regimeType,
    this.roomName,
    this.className,
    this.currentDuration,
    this.totalDuration,
    this.trainerEmail,
  }) : start = (dateDay != null && startTime != null)
           ? dateDay.add(startTime).toIso8601String()
           : null,
       end = (dateDay != null && endTime != null)
           ? dateDay.add(endTime).toIso8601String()
           : null;

  Map<String, dynamic> toJson() => _$OutputPublicScheduleDaoToJson(this);

  factory OutputPublicScheduleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputPublicScheduleDaoFromJson(json);
}
