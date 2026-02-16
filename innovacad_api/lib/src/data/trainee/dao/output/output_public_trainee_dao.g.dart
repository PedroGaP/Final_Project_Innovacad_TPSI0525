// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_public_trainee_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputPublicTraineeDao _$OutputPublicTraineeDaoFromJson(
  Map<String, dynamic> json,
) => OutputPublicTraineeDao(
  username: json['username'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as Object),
  traineeId: json['trainee_id'] as String,
  birthdayDate: const DateTimeConverter().fromJson(
    json['birthday_date'] as Object,
  ),
);

Map<String, dynamic> _$OutputPublicTraineeDaoToJson(
  OutputPublicTraineeDao instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'username': instance.username,
  'role': instance.role,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'trainee_id': instance.traineeId,
  'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
};
