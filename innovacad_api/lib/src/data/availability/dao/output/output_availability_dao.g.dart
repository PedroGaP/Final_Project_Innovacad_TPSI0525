// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_availability_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputAvailabilityDao _$OutputAvailabilityDaoFromJson(
  Map<String, dynamic> json,
) => OutputAvailabilityDao(
  availabilityId: json['availability_id'] as String,
  trainerId: json['trainer_id'] as String,
  status: json['status'] as String,
  startDateTimestamp: const DateTimeConverter().fromJson(
    json['start_date_timestamp'] as Object,
  ),
  endDateTimestamp: const DateTimeConverter().fromJson(
    json['end_date_timestamp'] as Object,
  ),
);

Map<String, dynamic> _$OutputAvailabilityDaoToJson(
  OutputAvailabilityDao instance,
) => <String, dynamic>{
  'availability_id': instance.availabilityId,
  'trainer_id': instance.trainerId,
  'status': instance.status,
  'start_date_timestamp': const DateTimeConverter().toJson(
    instance.startDateTimestamp,
  ),
  'end_date_timestamp': const DateTimeConverter().toJson(
    instance.endDateTimestamp,
  ),
};
