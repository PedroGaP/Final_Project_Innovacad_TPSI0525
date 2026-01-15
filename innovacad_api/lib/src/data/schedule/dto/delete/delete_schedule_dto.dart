import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_schedule_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteScheduleDto {
  @annotation.JsonKey(name: 'schedule_id')
  final String scheduleId;

  DeleteScheduleDto({required this.scheduleId});

  Map<String, dynamic> toJson() => _$DeleteScheduleDtoToJson(this);

  factory DeleteScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteScheduleDtoFromJson(json);
}
