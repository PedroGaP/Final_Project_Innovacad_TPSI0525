// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_enrollment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateEnrollmentDto _$UpdateEnrollmentDtoFromJson(Map<String, dynamic> json) =>
    UpdateEnrollmentDto(
      enrollmentId: json['enrollment_id'] as String,
      classId: json['class_id'] as String?,
      traineeId: json['trainee_id'] as String?,
      finalGrade: (json['final_grade'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UpdateEnrollmentDtoToJson(
  UpdateEnrollmentDto instance,
) => <String, dynamic>{
  'enrollment_id': instance.enrollmentId,
  'class_id': instance.classId,
  'trainee_id': instance.traineeId,
  'final_grade': instance.finalGrade,
};
