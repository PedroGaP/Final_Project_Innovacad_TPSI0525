// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trainee _$TraineeFromJson(Map<String, dynamic> json) => Trainee(
  id: json['id'] as String,
  username: json['username'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  traineeId: json['trainee_id'] as String,
  birthdayDate: const DateTimeConverter().fromJson(
    json['birthday_date'] as Object,
  ),
  token: json['token'] as String?,
);

Map<String, dynamic> _$TraineeToJson(Trainee instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'token': instance.token,
  'role': instance.role,
  'trainee_id': instance.traineeId,
  'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
};
