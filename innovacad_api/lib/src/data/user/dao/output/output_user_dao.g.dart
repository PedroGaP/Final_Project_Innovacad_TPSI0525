// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_user_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputUserDao _$OutputUserDaoFromJson(Map<String, dynamic> json) =>
    OutputUserDao(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: const DateTimeConverter().fromJson(
        json['createdAt'] as Object,
      ),
      role: json['role'] as String,
      image: json['image'] as String?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$OutputUserDaoToJson(OutputUserDao instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'role': instance.role,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'image': instance.image,
      'token': instance.token,
    };
