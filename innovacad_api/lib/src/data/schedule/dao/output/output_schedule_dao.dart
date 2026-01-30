import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_schedule_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputScheduleDao {
  @annotation.JsonKey(name: 'schedule_id')
  final String? scheduleId;

  @annotation.JsonKey(name: 'regime_type')
  final String? regimeType;

  @annotation.JsonKey(name: 'module_name')
  final String? moduleName;

  @annotation.JsonKey(name: 'trainer_name')
  final String? trainerName;

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
  final String? isOnline;

  @annotation.JsonKey(name: 'room_name')
  final String? roomName;

  OutputScheduleDao({
    this.scheduleId,
    this.moduleName,
    this.trainerName,
    this.startTime,
    this.endTime,
    this.isOnline,
    this.dateDay,
    this.regimeType,
    this.roomName,
  });

  Map<String, dynamic> toJson() => _$OutputScheduleDaoToJson(this);

  factory OutputScheduleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputScheduleDaoFromJson(json);
}
