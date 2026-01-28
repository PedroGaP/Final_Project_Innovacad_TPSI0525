// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_class_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputClassDao _$OutputClassDaoFromJson(Map<String, dynamic> json) =>
    OutputClassDao(
      classId: json['class_id'] as String,
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
      modules: (json['modules'] as List<dynamic>)
          .map((e) => OutputClassModuleDao.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OutputClassDaoToJson(OutputClassDao instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
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
      'modules': instance.modules,
    };

const _$ClassStatusEnumEnumMap = {
  ClassStatusEnum.ongoing: 'ongoing',
  ClassStatusEnum.starting: 'starting',
  ClassStatusEnum.finished: 'finished',
};
