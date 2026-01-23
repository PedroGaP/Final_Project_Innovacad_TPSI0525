import 'package:innovacad_mobile/utils/date_time_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name') // Changeable
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'role')
  final String role;

  @JsonKey(name: 'createdAt')
  @DateTimeConverter()
  final DateTime createdAt;

  @JsonKey(name: 'image') // Changeable
  final String? image;

  @JsonKey(name: 'token')
  final String? token;

  @JsonKey(name: 'session_token')
  final String? sessionToken;

  @JsonKey(name: 'emailVerified')
  final bool verified;

  @JsonKey(name: 'twoFactorEnabled', defaultValue: false)
  final bool twoFactorEnabled;

  bool get isGuest => id.isEmpty;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.role,
    required this.verified,
    required this.twoFactorEnabled,
    this.image,
    this.token,
    this.sessionToken,
  });

  factory UserModel.guest() => UserModel(
    id: "",
    username: "",
    email: "",
    name: "",
    createdAt: DateTime.now(),
    role: "",
    verified: false,
    twoFactorEnabled: false,
  );

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
