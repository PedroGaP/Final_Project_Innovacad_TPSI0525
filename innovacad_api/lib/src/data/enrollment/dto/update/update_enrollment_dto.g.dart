// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_enrollment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateEnrollmentDto _$UpdateEnrollmentDtoFromJson(Map<String, dynamic> json) =>
    UpdateEnrollmentDto(
      classId: json['class_id'] as String?,
      traineeId: json['trainee_id'] as String?,
      finalGrade: json['final_grade'] as String?,
    );

Map<String, dynamic> _$UpdateEnrollmentDtoToJson(
  UpdateEnrollmentDto instance,
) => <String, dynamic>{
  'class_id': instance.classId,
  'trainee_id': instance.traineeId,
  'final_grade': instance.finalGrade,
};
