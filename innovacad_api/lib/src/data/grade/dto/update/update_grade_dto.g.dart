// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_grade_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateGradeDto _$UpdateGradeDtoFromJson(Map<String, dynamic> json) =>
    UpdateGradeDto(
      gradeId: json['grade_id'] as String,
      classModuleId: json['class_module_id'] as String?,
      traineeId: json['trainee_id'] as String?,
      grade: (json['grade'] as num?)?.toDouble(),
      gradeType: json['grade_type'] as String?,
    );

Map<String, dynamic> _$UpdateGradeDtoToJson(UpdateGradeDto instance) =>
    <String, dynamic>{
      'grade_id': instance.gradeId,
      'class_module_id': instance.classModuleId,
      'trainee_id': instance.traineeId,
      'grade': instance.grade,
      'grade_type': instance.gradeType,
    };
