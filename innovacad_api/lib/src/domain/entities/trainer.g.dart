// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trainer _$TrainerFromJson(Map<String, dynamic> json) => Trainer(
  id: json['id'] as String,
  username: json['username'] as String,
  name: json['name'] as String,
  trainerId: json['trainer_id'] as String,
  birthdayDate: const DateTimeConverter().fromJson(
    json['birthday_date'] as Object,
  ),
)..token = json['token'] as String?;

Map<String, dynamic> _$TrainerToJson(Trainer instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'name': instance.name,
  'token': instance.token,
  'trainer_id': instance.trainerId,
  'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
};
