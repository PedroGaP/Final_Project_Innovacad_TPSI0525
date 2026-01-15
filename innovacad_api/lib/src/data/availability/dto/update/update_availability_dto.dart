import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_availability_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateAvailabilityDto {
  @annotation.JsonKey(name: 'availability_id')
  final String availabilityId;

  @annotation.JsonKey(name: 'trainer_id')
  final String? trainerId;

  @annotation.JsonKey(name: 'status')
  final String? status;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @DateTimeConverter()
  final DateTime? startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @DateTimeConverter()
  final DateTime? endDateTimestamp;

  UpdateAvailabilityDto({
    required this.availabilityId,
    this.trainerId,
    this.status,
    this.startDateTimestamp,
    this.endDateTimestamp,
  });

  Map<String, dynamic> toJson() => _$UpdateAvailabilityDtoToJson(this);

  factory UpdateAvailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateAvailabilityDtoFromJson(json);
}
