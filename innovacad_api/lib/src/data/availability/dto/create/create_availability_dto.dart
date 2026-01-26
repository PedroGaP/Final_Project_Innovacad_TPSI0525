import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_availability_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class CreateAvailabilityDto {
  @annotation.JsonKey(name: 'trainer_id')
  @vaden.JsonKey('trainer_id')
  final String trainerId;

  @annotation.JsonKey(name: 'status')
  final String status;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @vaden.JsonKey('start_date_timestamp')
  @DateTimeConverter()
  final DateTime startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @vaden.JsonKey('end_date_timestamp')
  @DateTimeConverter()
  final DateTime endDateTimestamp;

  CreateAvailabilityDto({
    required this.trainerId,
    required this.status,
    required this.startDateTimestamp,
    required this.endDateTimestamp,
  });

  Map<String, dynamic> toJson() => _$CreateAvailabilityDtoToJson(this);

  factory CreateAvailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAvailabilityDtoFromJson(json);
}
