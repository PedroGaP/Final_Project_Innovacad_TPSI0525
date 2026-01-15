import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_schedule_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateScheduleDto {
  @annotation.JsonKey(name: 'schedule_id')
  final String scheduleId;

  @annotation.JsonKey(name: 'class_module_id')
  final String? classModuleId;

  @annotation.JsonKey(name: 'trainer_id')
  final String? trainerId;

  @annotation.JsonKey(name: 'availability_id')
  final String? availabilityId;

  @annotation.JsonKey(name: 'room_id')
  final int? roomId;

  @annotation.JsonKey(name: 'online')
  final bool? online;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @DateTimeConverter()
  final DateTime? startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @DateTimeConverter()
  final DateTime? endDateTimestamp;

  UpdateScheduleDto({
    required this.scheduleId,
    this.classModuleId,
    this.trainerId,
    this.availabilityId,
    this.roomId,
    this.online,
    this.startDateTimestamp,
    this.endDateTimestamp,
  });

  Map<String, dynamic> toJson() => _$UpdateScheduleDtoToJson(this);

  factory UpdateScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateScheduleDtoFromJson(json);
}
