// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_enrollment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateEnrollmentDto _$CreateEnrollmentDtoFromJson(Map<String, dynamic> json) =>
    CreateEnrollmentDto(
      classId: json['class_id'] as String,
      traineeId: json['trainee_id'] as String,
      finalGrade: (json['final_grade'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateEnrollmentDtoToJson(
  CreateEnrollmentDto instance,
) => <String, dynamic>{
  'class_id': instance.classId,
  'trainee_id': instance.traineeId,
  'final_grade': instance.finalGrade,
};
