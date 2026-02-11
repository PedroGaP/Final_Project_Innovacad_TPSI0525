// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_enrollment_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputEnrollmentDao _$OutputEnrollmentDaoFromJson(Map<String, dynamic> json) =>
    OutputEnrollmentDao(
      enrollmentId: json['enrollment_id'] as String,
      classId: json['class_id'] as String,
      traineeId: json['trainee_id'] as String,
      finalGrade:
          _$JsonConverterFromJson<Object, double>(
            json['final_grade'],
            const DoubleConverter().fromJson,
          ) ??
          0,
    );

Map<String, dynamic> _$OutputEnrollmentDaoToJson(
  OutputEnrollmentDao instance,
) => <String, dynamic>{
  'enrollment_id': instance.enrollmentId,
  'class_id': instance.classId,
  'trainee_id': instance.traineeId,
  'final_grade': _$JsonConverterToJson<Object, double>(
    instance.finalGrade,
    const DoubleConverter().toJson,
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
