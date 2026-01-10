// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassModelCreateDto _$ClassModelCreateDtoFromJson(Map<String, dynamic> json) =>
    ClassModelCreateDto(
      course_id: json['course_id'] as String,
      location: json['location'] as String,
      identifier: json['identifier'] as String,
      status: $enumDecode(_$ClassStatusEnumEnumMap, json['status']),
      start_date_timestamp: DateTime.parse(
        json['start_date_timestamp'] as String,
      ),
      end_date_timestamp: DateTime.parse(json['end_date_timestamp'] as String),
    );

Map<String, dynamic> _$ClassModelCreateDtoToJson(
  ClassModelCreateDto instance,
) => <String, dynamic>{
  'course_id': instance.course_id,
  'location': instance.location,
  'identifier': instance.identifier,
  'status': _$ClassStatusEnumEnumMap[instance.status]!,
  'start_date_timestamp': instance.start_date_timestamp.toIso8601String(),
  'end_date_timestamp': instance.end_date_timestamp.toIso8601String(),
};

const _$ClassStatusEnumEnumMap = {
  ClassStatusEnum.ongoing: 'ongoing',
  ClassStatusEnum.starting: 'starting',
  ClassStatusEnum.finished: 'finished',
};
