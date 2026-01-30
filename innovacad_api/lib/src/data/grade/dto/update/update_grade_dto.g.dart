// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_grade_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateGradeDto _$UpdateGradeDtoFromJson(Map<String, dynamic> json) =>
    UpdateGradeDto(
      classModuleId: json['class_module_id'] as String?,
      traineeId: json['trainee_id'] as String?,
      grade: _$JsonConverterFromJson<Object, double>(
        json['grade'],
        const DoubleConverter().fromJson,
      ),
      gradeType: json['grade_type'] as String?,
    );

Map<String, dynamic> _$UpdateGradeDtoToJson(UpdateGradeDto instance) =>
    <String, dynamic>{
      'class_module_id': instance.classModuleId,
      'trainee_id': instance.traineeId,
      'grade': _$JsonConverterToJson<Object, double>(
        instance.grade,
        const DoubleConverter().toJson,
      ),
      'grade_type': instance.gradeType,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
