// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_trainer_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputTrainerDao _$OutputTrainerDaoFromJson(
  Map<String, dynamic> json,
) => OutputTrainerDao(
  id: json['id'] as String,
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as Object),
  email: json['email'] as String,
  name: json['name'] as String,
  username: json['username'] as String,
  role: json['role'] as String,
  verified: OutputUserDao.convertBoolean(json, 'emailVerified') as bool?,
  twoFactorEnabled:
      OutputUserDao.convertBoolean(json, 'twoFactorEnabled') as bool? ?? false,
  trainerId: json['trainer_id'] as String,
  birthdayDate: const DateTimeConverter().fromJson(
    json['birthday_date'] as Object,
  ),
  skills: (json['skills'] as List<dynamic>)
      .map((e) => TrainerSkillDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  isCoordinator: json['is_coordinator'] as bool?,
  coordinatedClassIds: (json['coordinated_class_ids'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as String)),
  image: json['image'] as String?,
  token: json['token'] as String?,
  sessionToken: json['session_token'] as String?,
);

Map<String, dynamic> _$OutputTrainerDaoToJson(OutputTrainerDao instance) =>
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
      'twoFactorEnabled': instance.twoFactorEnabled,
      'coordinated_class_ids': instance.coordinatedClassIds,
      'trainer_id': instance.trainerId,
      'birthday_date': const DateTimeConverter().toJson(instance.birthdayDate),
      'skills': instance.skills,
      'is_coordinator': instance.isCoordinator,
    };
