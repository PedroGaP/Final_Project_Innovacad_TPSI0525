// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trainee _$TraineeFromJson(Map<String, dynamic> json) => Trainee(
  trainee_id: json['trainee_id'] as String,
  user_id: json['user_id'] as String,
  birthday_date: const DateTimeConverter().fromJson(
    json['birthday_date'] as Object,
  ),
);

Map<String, dynamic> _$TraineeToJson(Trainee instance) => <String, dynamic>{
  'trainee_id': instance.trainee_id,
  'user_id': instance.user_id,
  'birthday_date': const DateTimeConverter().toJson(instance.birthday_date),
};
