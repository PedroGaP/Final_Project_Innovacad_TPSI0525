// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_user_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraineeUserDao _$TraineeUserDaoFromJson(Map<String, dynamic> json) =>
    TraineeUserDao(
      userId: json['id'] as String,
      traineeId: json['trainee_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: const DateTimeConverter().fromJson(
        json['createdAt'] as Object,
      ),
      birthdayDate: const DateTimeConverter().fromJson(
        json['birthday_date'] as Object,
      ),
      role: json['role'] as String,
      token: json['token'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$TraineeUserDaoToJson(TraineeUserDao instance) =>
    <String, dynamic>{
      'id': instance.userId,
      'trainee_id': instance.traineeId,
      'email': instance.email,
      'name': instance.name,
      'username': instance.username,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
      'token': instance.token,
      'role': instance.role,
      'image': instance.image,
    };
