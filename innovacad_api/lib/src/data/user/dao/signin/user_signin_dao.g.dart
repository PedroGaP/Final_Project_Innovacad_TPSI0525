// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_signin_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSigninDao _$UserSigninDaoFromJson(Map<String, dynamic> json) =>
    UserSigninDao(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: const DateTimeConverter().fromJson(
        json['createdAt'] as Object,
      ),
      role: json['role'] as String,
      verified: json['emailVerified'] as bool,
      image: json['image'] as String?,
      token: json['token'] as String?,
      sessionToken: json['session_token'] as String?,
    );

Map<String, dynamic> _$UserSigninDaoToJson(UserSigninDao instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'role': instance.role,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'image': instance.image,
      'token': instance.token,
      'session_token': instance.sessionToken,
      'emailVerified': instance.verified,
    };
