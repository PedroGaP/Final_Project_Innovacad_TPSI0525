// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as Object),
  role: json['role'] as String,
  verified: json['emailVerified'] as bool,
  twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
  image: json['image'] as String?,
  token: json['token'] as String?,
  sessionToken: json['session_token'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
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
  'twoFactorEnabled': instance.twoFactorEnabled,
};
