import 'package:innovacad_api/src/core/core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'output_account_dao.g.dart';

@JsonSerializable()
class OutputAccountDao {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'providerId')
  final String providerId;

  @JsonKey(name: 'createdAt')
  @DateTimeConverter()
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  @DateTimeConverter()
  final DateTime updatedAt;

  @JsonKey(name: 'accountId')
  final String accountId;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'scopes')
  final List<String> scopes;

  OutputAccountDao({
    required this.id,
    required this.providerId,
    required this.createdAt,
    required this.updatedAt,
    required this.accountId,
    required this.userId,
    this.scopes = const [],
  });

  factory OutputAccountDao.fromJson(Map<String, dynamic> json) =>
      _$OutputAccountDaoFromJson(json);

  Map<String, dynamic> toJson() => _$OutputAccountDaoToJson(this);
}
