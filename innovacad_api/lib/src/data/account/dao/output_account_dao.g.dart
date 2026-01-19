// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_account_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputAccountDao _$OutputAccountDaoFromJson(
  Map<String, dynamic> json,
) => OutputAccountDao(
  id: json['id'] as String,
  providerId: json['providerId'] as String,
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const DateTimeConverter().fromJson(json['updatedAt'] as Object),
  accountId: json['accountId'] as String,
  userId: json['userId'] as String,
  scopes:
      (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$OutputAccountDaoToJson(OutputAccountDao instance) =>
    <String, dynamic>{
      'id': instance.id,
      'providerId': instance.providerId,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
      'accountId': instance.accountId,
      'userId': instance.userId,
      'scopes': instance.scopes,
    };
