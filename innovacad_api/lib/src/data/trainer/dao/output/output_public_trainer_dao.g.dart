// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_public_trainer_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputPublicTrainerDao _$OutputPublicTrainerDaoFromJson(
  Map<String, dynamic> json,
) => OutputPublicTrainerDao(
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as Object),
  email: json['email'] as String,
  name: json['name'] as String,
  username: json['username'] as String,
  role: json['role'] as String,
  trainerId: json['trainer_id'] as String,
  birthdayDate: const DateTimeConverter().fromJson(
    json['birthday_date'] as Object,
  ),
  isCoordinator: json['is_coordinator'] as bool?,
  coordinatedClassIds: (json['coordinated_class_ids'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  image: json['image'] as String?,
);

Map<String, dynamic> _$OutputPublicTrainerDaoToJson(
  OutputPublicTrainerDao instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'username': instance.username,
  'role': instance.role,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'image': instance.image,
  'coordinated_class_ids': instance.coordinatedClassIds,
  'trainer_id': instance.trainerId,
  'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
  'is_coordinator': instance.isCoordinator,
};
