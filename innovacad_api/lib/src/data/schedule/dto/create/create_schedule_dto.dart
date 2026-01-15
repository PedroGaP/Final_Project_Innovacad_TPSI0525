import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_schedule_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateScheduleDto {
  @annotation.JsonKey(name: 'class_module_id')
  final String classModuleId;

  @annotation.JsonKey(name: 'trainer_id')
  final String trainerId;

  @annotation.JsonKey(name: 'availability_id')
  final String availabilityId;

  @annotation.JsonKey(name: 'room_id')
  final int? roomId;

  @annotation.JsonKey(name: 'online')
  final bool online;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @DateTimeConverter()
  final DateTime startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @DateTimeConverter()
  final DateTime endDateTimestamp;

  CreateScheduleDto({
    required this.classModuleId,
    required this.trainerId,
    required this.availabilityId,
    this.roomId,
    required this.online,
    required this.startDateTimestamp,
    required this.endDateTimestamp,
  });

  Map<String, dynamic> toJson() => _$CreateScheduleDtoToJson(this);

  factory CreateScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduleDtoFromJson(json);
}
