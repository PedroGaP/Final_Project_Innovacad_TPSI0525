// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_trainee_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputTraineeDao _$OutputTraineeDaoFromJson(Map<String, dynamic> json) =>
    OutputTraineeDao(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: const DateTimeConverter().fromJson(
        json['createdAt'] as Object,
      ),
      token: json['token'] as String?,
      image: json['image'] as String?,
      traineeId: json['trainee_id'] as String,
      birthdayDate: const DateTimeConverter().fromJson(
        json['birthday_date'] as Object,
      ),
    );

Map<String, dynamic> _$OutputTraineeDaoToJson(OutputTraineeDao instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'role': instance.role,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'image': instance.image,
      'token': instance.token,
      'trainee_id': instance.traineeId,
      'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
    };
