// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_grade_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputGradeDao _$OutputGradeDaoFromJson(
  Map<String, dynamic> json,
) => OutputGradeDao(
  gradeId: json['grade_id'] as String,
  classModuleId: json['class_module_id'] as String,
  traineeId: json['trainee_id'] as String,
  grade: (json['grade'] as num).toDouble(),
  gradeType: json['grade_type'] as String,
  createdAt: const DateTimeConverter().fromJson(json['created_at'] as Object),
  updatedAt: const DateTimeConverter().fromJson(json['updated_at'] as Object),
);

Map<String, dynamic> _$OutputGradeDaoToJson(OutputGradeDao instance) =>
    <String, dynamic>{
      'grade_id': instance.gradeId,
      'class_module_id': instance.classModuleId,
      'trainee_id': instance.traineeId,
      'grade': instance.grade,
      'grade_type': instance.gradeType,
      'created_at': const DateTimeConverter().toJson(instance.createdAt),
      'updated_at': const DateTimeConverter().toJson(instance.updatedAt),
    };
