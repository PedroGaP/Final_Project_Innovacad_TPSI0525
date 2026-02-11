import 'package:vaden/vaden.dart' as v;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'save_summary_dto.g.dart';

@v.DTO()
@annotation.JsonSerializable()
class SaveSummaryDto {
  @annotation.JsonKey(name: 'schedule_id')
  @v.JsonKey('schedule_id')
  final String scheduleId;

  @annotation.JsonKey(name: 'contents')
  @v.JsonKey('contents')
  final String contents;

  @annotation.JsonKey(name: 'attendances')
  @v.JsonKey('attendances')
  final List<AttendanceItemDto> attendances;

  SaveSummaryDto({
    required this.scheduleId,
    required this.contents,
    required this.attendances,
  });

  Map<String, dynamic> toJson() => _$SaveSummaryDtoToJson(this);
  factory SaveSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$SaveSummaryDtoFromJson(json);
}

@v.DTO()
@annotation.JsonSerializable()
class AttendanceItemDto {
  @annotation.JsonKey(name: 'trainee_id')
  @v.JsonKey('trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'is_absent')
  @v.JsonKey('is_absent')
  final bool isAbsent;

  AttendanceItemDto({required this.traineeId, required this.isAbsent});

  Map<String, dynamic> toJson() => _$AttendanceItemDtoToJson(this);
  factory AttendanceItemDto.fromJson(Map<String, dynamic> json) =>
      _$AttendanceItemDtoFromJson(json);
}
