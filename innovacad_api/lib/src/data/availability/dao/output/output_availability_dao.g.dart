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
  dateDay: const DateTimeConverter().fromJson(json['date_day'] as Object),
  slotNumber: const NumberConverter().fromJson(json['slot_number'] as Object),
  isBooked: const NumberConverter().fromJson(json['is_booked'] as Object),
);

Map<String, dynamic> _$OutputAvailabilityDaoToJson(
  OutputAvailabilityDao instance,
) => <String, dynamic>{
  'availability_id': instance.availabilityId,
  'trainer_id': instance.trainerId,
  'date_day': const DateTimeConverter().toJson(instance.dateDay),
  'slot_number': const NumberConverter().toJson(instance.slotNumber),
  'is_booked': const NumberConverter().toJson(instance.isBooked),
};
