// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_availability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAvailabilityDto _$CreateAvailabilityDtoFromJson(
  Map<String, dynamic> json,
) => CreateAvailabilityDto(
  trainerId: json['trainer_id'] as String,
  dateDay: const DateTimeConverter().fromJson(json['date_day'] as Object),
  slotNumber: (json['slot_number'] as num).toInt(),
  isBooked: (json['is_booked'] as num).toInt(),
);

Map<String, dynamic> _$CreateAvailabilityDtoToJson(
  CreateAvailabilityDto instance,
) => <String, dynamic>{
  'trainer_id': instance.trainerId,
  'date_day': const DateTimeConverter().toJson(instance.dateDay),
  'slot_number': instance.slotNumber,
  'is_booked': instance.isBooked,
};
