// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_trainer_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputTrainerDao _$OutputTrainerDaoFromJson(Map<String, dynamic> json) =>
    OutputTrainerDao(
      trainerId: json['trainer_id'] as String,
      userId: json['user_id'] as String,
      birthdayDate: const DateTimeConverter().fromJson(
        json['birthday_date'] as Object,
      ),
      specialization: json['specialization'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      createdAt: const DateTimeConverter().fromJson(
        json['createdAt'] as Object,
      ),
      token: json['token'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$OutputTrainerDaoToJson(OutputTrainerDao instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'role': instance.role,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'image': instance.image,
      'token': instance.token,
      'trainer_id': instance.trainerId,
      'user_id': instance.userId,
      'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
      'specialization': instance.specialization,
    };
