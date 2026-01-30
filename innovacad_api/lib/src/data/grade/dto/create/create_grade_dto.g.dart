// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_grade_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGradeDto _$CreateGradeDtoFromJson(Map<String, dynamic> json) =>
    CreateGradeDto(
      classModuleId: json['class_module_id'] as String,
      traineeId: json['trainee_id'] as String,
      grade: json['grade'] as String,
      gradeType: json['grade_type'] as String,
    );

Map<String, dynamic> _$CreateGradeDtoToJson(CreateGradeDto instance) =>
    <String, dynamic>{
      'class_module_id': instance.classModuleId,
      'trainee_id': instance.traineeId,
      'grade': instance.grade,
      'grade_type': instance.gradeType,
    };
