// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_availability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAvailabilityDto _$CreateAvailabilityDtoFromJson(
  Map<String, dynamic> json,
) => CreateAvailabilityDto(
  trainerId: json['trainer_id'] as String,
  status: json['status'] as String,
  startDateTimestamp: const DateTimeConverter().fromJson(
    json['start_date_timestamp'] as Object,
  ),
  endDateTimestamp: const DateTimeConverter().fromJson(
    json['end_date_timestamp'] as Object,
  ),
);

Map<String, dynamic> _$CreateAvailabilityDtoToJson(
  CreateAvailabilityDto instance,
) => <String, dynamic>{
  'trainer_id': instance.trainerId,
  'status': instance.status,
  'start_date_timestamp': const DateTimeConverter().toJson(
    instance.startDateTimestamp,
  ),
  'end_date_timestamp': const DateTimeConverter().toJson(
    instance.endDateTimestamp,
  ),
};
