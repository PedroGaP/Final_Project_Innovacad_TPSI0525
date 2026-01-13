// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model_update_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassModelUpdateDto _$ClassModelUpdateDtoFromJson(Map<String, dynamic> json) =>
    ClassModelUpdateDto(
      course_id: json['course_id'] as String?,
      location: json['location'] as String?,
      identifier: json['identifier'] as String?,
      status: $enumDecodeNullable(_$ClassStatusEnumEnumMap, json['status']),
      start_date_timestamp: json['start_date_timestamp'] == null
          ? null
          : DateTime.parse(json['start_date_timestamp'] as String),
      end_date_timestamp: json['end_date_timestamp'] == null
          ? null
          : DateTime.parse(json['end_date_timestamp'] as String),
    );

Map<String, dynamic> _$ClassModelUpdateDtoToJson(
  ClassModelUpdateDto instance,
) => <String, dynamic>{
  'course_id': instance.course_id,
  'location': instance.location,
  'identifier': instance.identifier,
  'status': _$ClassStatusEnumEnumMap[instance.status],
  'start_date_timestamp': instance.start_date_timestamp?.toIso8601String(),
  'end_date_timestamp': instance.end_date_timestamp?.toIso8601String(),
};

const _$ClassStatusEnumEnumMap = {
  ClassStatusEnum.ongoing: 'ongoing',
  ClassStatusEnum.starting: 'starting',
  ClassStatusEnum.finished: 'finished',
};
