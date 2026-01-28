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
  final int roomId;

  @annotation.JsonKey(name: 'is_online')
  final bool isOnline;

  @annotation.JsonKey(name: 'regime_type')
  final int regimeType;

  @annotation.JsonKey(name: 'total_hours')
  final double totalHours;

  CreateScheduleDto({
    required this.classModuleId,
    required this.trainerId,
    required this.availabilityId,
    required this.roomId,
    required this.isOnline,
    required this.regimeType,
    required this.totalHours,
  });

  Map<String, dynamic> toJson() => _$CreateScheduleDtoToJson(this);

  factory CreateScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduleDtoFromJson(json);
}
