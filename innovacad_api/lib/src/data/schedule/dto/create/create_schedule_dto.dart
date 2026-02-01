import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:vaden/vaden.dart' as v;

part 'create_schedule_dto.g.dart';

@annotation.JsonSerializable()
@v.DTO()
class CreateScheduleDto {
  @annotation.JsonKey(name: 'class_module_id')
  @v.JsonKey('class_module_id')
  final String classModuleId;

  @annotation.JsonKey(name: 'trainer_id')
  @v.JsonKey('trainer_id')
  final String trainerId;

  @annotation.JsonKey(name: 'room_id')
  @v.JsonKey('room_id')
  final int? roomId;

  @annotation.JsonKey(name: 'start_time')
  @v.JsonKey('start_time')
  final DateTime startTime;

  @annotation.JsonKey(name: 'end_time')
  @v.JsonKey('end_time')
  final DateTime endTime;

  @annotation.JsonKey(name: 'force_trainer_change')
  @v.JsonKey('force_trainer_change')
  final bool forceTrainerChange;

  CreateScheduleDto({
    required this.classModuleId,
    required this.trainerId,
    this.roomId,
    required this.startTime,
    required this.endTime,
    this.forceTrainerChange = false,
  });

  Map<String, dynamic> toJson() => _$CreateScheduleDtoToJson(this);

  factory CreateScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduleDtoFromJson(json);
}
