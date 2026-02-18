// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_public_user_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputPublicUserDao _$OutputPublicUserDaoFromJson(
  Map<String, dynamic> json,
) => OutputPublicUserDao(
  username: json['username'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as Object),
  role: json['role'] as String,
  isCoordinator:
      OutputPublicUserDao.convertBoolean(json, 'is_coordinator') as bool?,
  coordinatedClassIds: (json['coordinated_class_ids'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  image: json['image'] as String?,
);

Map<String, dynamic> _$OutputPublicUserDaoToJson(
  OutputPublicUserDao instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'username': instance.username,
  'role': instance.role,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'image': instance.image,
  'is_coordinator': instance.isCoordinator,
  'coordinated_class_ids': instance.coordinatedClassIds,
};
