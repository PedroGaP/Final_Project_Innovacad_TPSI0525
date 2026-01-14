// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_user_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerUserDao _$TrainerUserDaoFromJson(Map<String, dynamic> json) =>
    TrainerUserDao(
      userId: json['id'] as String,
      traineeId: json['trainer_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: const DateTimeConverter().fromJson(
        json['createdAt'] as Object,
      ),
      birthdayDate: const DateTimeConverter().fromJson(
        json['birthday_date'] as Object,
      ),
      specialization: json['specialization'] as String,
      token: json['token'] as String,
      role: json['role'] as String,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$TrainerUserDaoToJson(TrainerUserDao instance) =>
    <String, dynamic>{
      'id': instance.userId,
      'trainer_id': instance.traineeId,
      'email': instance.email,
      'name': instance.name,
      'username': instance.username,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
      'specialization': instance.specialization,
      'token': instance.token,
      'role': instance.role,
      'image': instance.image,
    };
