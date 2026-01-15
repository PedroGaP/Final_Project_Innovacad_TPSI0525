// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_class_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateClassDto _$UpdateClassDtoFromJson(Map<String, dynamic> json) =>
    UpdateClassDto(
      classId: json['class_id'] as String,
      courseId: json['course_id'] as String?,
      location: json['location'] as String?,
      identifier: json['identifier'] as String?,
      status: $enumDecodeNullable(_$ClassStatusEnumEnumMap, json['status']),
      startDateTimestamp: _$JsonConverterFromJson<Object, DateTime>(
        json['start_date_timestamp'],
        const DateTimeConverter().fromJson,
      ),
      endDateTimestamp: _$JsonConverterFromJson<Object, DateTime>(
        json['end_date_timestamp'],
        const DateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$UpdateClassDtoToJson(UpdateClassDto instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
      'course_id': instance.courseId,
      'location': instance.location,
      'identifier': instance.identifier,
      'status': _$ClassStatusEnumEnumMap[instance.status],
      'start_date_timestamp': _$JsonConverterToJson<Object, DateTime>(
        instance.startDateTimestamp,
        const DateTimeConverter().toJson,
      ),
      'end_date_timestamp': _$JsonConverterToJson<Object, DateTime>(
        instance.endDateTimestamp,
        const DateTimeConverter().toJson,
      ),
    };

const _$ClassStatusEnumEnumMap = {
  ClassStatusEnum.ongoing: 'ongoing',
  ClassStatusEnum.starting: 'starting',
  ClassStatusEnum.finished: 'finished',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
