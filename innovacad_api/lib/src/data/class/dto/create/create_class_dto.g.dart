// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_class_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateClassDto _$CreateClassDtoFromJson(Map<String, dynamic> json) =>
    CreateClassDto(
      courseId: json['course_id'] as String,
      location: json['location'] as String,
      identifier: json['identifier'] as String,
      status: $enumDecode(_$ClassStatusEnumEnumMap, json['status']),
      startDateTimestamp: const DateTimeConverter().fromJson(
        json['start_date_timestamp'] as Object,
      ),
      endDateTimestamp: const DateTimeConverter().fromJson(
        json['end_date_timestamp'] as Object,
      ),
      modulesIds: (json['modules'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateClassDtoToJson(CreateClassDto instance) =>
    <String, dynamic>{
      'course_id': instance.courseId,
      'location': instance.location,
      'identifier': instance.identifier,
      'status': _$ClassStatusEnumEnumMap[instance.status]!,
      'start_date_timestamp': const DateTimeConverter().toJson(
        instance.startDateTimestamp,
      ),
      'end_date_timestamp': const DateTimeConverter().toJson(
        instance.endDateTimestamp,
      ),
      'modules': instance.modulesIds,
    };

const _$ClassStatusEnumEnumMap = {
  ClassStatusEnum.ongoing: 'ongoing',
  ClassStatusEnum.starting: 'starting',
  ClassStatusEnum.finished: 'finished',
};
