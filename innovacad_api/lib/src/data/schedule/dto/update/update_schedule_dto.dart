import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_schedule_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class UpdateScheduleDto {
  @annotation.JsonKey(name: 'trainer_id')
  @vaden.JsonKey('trainer_id')
  final String? trainerId;

  @annotation.JsonKey(name: 'room_id')
  @vaden.JsonKey('room_id')
  final int? roomId;

  @annotation.JsonKey(name: 'is_online')
  @vaden.JsonKey('is_online')
  final bool? isOnline;

  @annotation.JsonKey(name: 'regime_type')
  @vaden.JsonKey('regime_type')
  final int? regimeType;

  @annotation.JsonKey(name: 'start_time')
  @vaden.JsonKey('start_time')
  @DateTimeConverter()
  final DateTime? startTime;

  @annotation.JsonKey(name: 'end_time')
  @vaden.JsonKey('end_time')
  @DateTimeConverter()
  final DateTime? endTime;

  UpdateScheduleDto({
    this.trainerId,
    this.roomId,
    this.isOnline,
    this.regimeType,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => _$UpdateScheduleDtoToJson(this);

  factory UpdateScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateScheduleDtoFromJson(json);
}
