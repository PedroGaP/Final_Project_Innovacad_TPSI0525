// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_simple_schedule_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputSimpleScheduleDao _$OutputSimpleScheduleDaoFromJson(
  Map<String, dynamic> json,
) => OutputSimpleScheduleDao(
  classModuleId: json['class_module_id'] as String?,
  trainerId: json['trainer_id'] as String?,
  roomId: (json['room_id'] as num?)?.toInt(),
  isOnline: _$JsonConverterFromJson<Object, int>(
    json['is_online'],
    const NumberConverter().fromJson,
  ),
  regimeType: _$JsonConverterFromJson<Object, int>(
    json['regime_type'],
    const NumberConverter().fromJson,
  ),
  totalHours: _$JsonConverterFromJson<Object, double>(
    json['total_hours'],
    const DoubleConverter().fromJson,
  ),
  createdAt: _$JsonConverterFromJson<Object, DateTime>(
    json['created_at'],
    const DateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$OutputSimpleScheduleDaoToJson(
  OutputSimpleScheduleDao instance,
) => <String, dynamic>{
  'class_module_id': instance.classModuleId,
  'trainer_id': instance.trainerId,
  'room_id': instance.roomId,
  'is_online': _$JsonConverterToJson<Object, int>(
    instance.isOnline,
    const NumberConverter().toJson,
  ),
  'regime_type': _$JsonConverterToJson<Object, int>(
    instance.regimeType,
    const NumberConverter().toJson,
  ),
  'total_hours': _$JsonConverterToJson<Object, double>(
    instance.totalHours,
    const DoubleConverter().toJson,
  ),
  'created_at': _$JsonConverterToJson<Object, DateTime>(
    instance.createdAt,
    const DateTimeConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
