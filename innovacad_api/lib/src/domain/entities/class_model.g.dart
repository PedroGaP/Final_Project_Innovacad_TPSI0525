// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassModel _$ClassModelFromJson(Map<String, dynamic> json) => ClassModel(
  class_id: json['class_id'] as String,
  course_id: json['course_id'] as String,
  location: json['location'] as String,
  identifier: json['identifier'] as String,
  status: $enumDecode(_$ClassStatusEnumEnumMap, json['status']),
  start_date_timestamp: const DateTimeConverter().fromJson(
    json['start_date_timestamp'] as Object,
  ),
  end_date_timestamp: const DateTimeConverter().fromJson(
    json['end_date_timestamp'] as Object,
  ),
);

Map<String, dynamic> _$ClassModelToJson(ClassModel instance) =>
    <String, dynamic>{
      'class_id': instance.class_id,
      'course_id': instance.course_id,
      'location': instance.location,
      'identifier': instance.identifier,
      'status': _$ClassStatusEnumEnumMap[instance.status]!,
      'start_date_timestamp': const DateTimeConverter().toJson(
        instance.start_date_timestamp,
      ),
      'end_date_timestamp': const DateTimeConverter().toJson(
        instance.end_date_timestamp,
      ),
    };

const _$ClassStatusEnumEnumMap = {
  ClassStatusEnum.ongoing: 'ongoing',
  ClassStatusEnum.starting: 'starting',
  ClassStatusEnum.finished: 'finished',
};
