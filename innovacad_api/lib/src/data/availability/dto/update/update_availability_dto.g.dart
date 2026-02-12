// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_availability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAvailabilityDto _$UpdateAvailabilityDtoFromJson(
  Map<String, dynamic> json,
) => UpdateAvailabilityDto(
  trainerId: json['trainer_id'] as String?,
  dateDay: _$JsonConverterFromJson<Object, DateTime>(
    json['date_day'],
    const DateTimeConverter().fromJson,
  ),
  slotNumber: (json['slot_number'] as num?)?.toInt(),
  isBooked: (json['is_booked'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateAvailabilityDtoToJson(
  UpdateAvailabilityDto instance,
) => <String, dynamic>{
  'trainer_id': instance.trainerId,
  'date_day': _$JsonConverterToJson<Object, DateTime>(
    instance.dateDay,
    const DateTimeConverter().toJson,
  ),
  'slot_number': instance.slotNumber,
  'is_booked': instance.isBooked,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
