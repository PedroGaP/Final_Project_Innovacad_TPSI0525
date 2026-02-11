// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_grade_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchGradeDto _$BatchGradeDtoFromJson(Map<String, dynamic> json) =>
    BatchGradeDto(
      classModuleId: json['class_module_id'] as String,
      grades: (json['grades'] as List<dynamic>)
          .map((e) => GradeItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BatchGradeDtoToJson(BatchGradeDto instance) =>
    <String, dynamic>{
      'class_module_id': instance.classModuleId,
      'grades': instance.grades,
    };

GradeItemDto _$GradeItemDtoFromJson(Map<String, dynamic> json) => GradeItemDto(
  traineeId: json['trainee_id'] as String,
  grade: (json['grade'] as num).toDouble(),
  gradeType: json['grade_type'] as String,
);

Map<String, dynamic> _$GradeItemDtoToJson(GradeItemDto instance) =>
    <String, dynamic>{
      'trainee_id': instance.traineeId,
      'grade': instance.grade,
      'grade_type': instance.gradeType,
    };
