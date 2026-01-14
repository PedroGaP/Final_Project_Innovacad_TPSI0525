import 'package:json_annotation/json_annotation.dart' as js;

part 'user.g.dart';

@js.JsonSerializable()
class User {
  @js.JsonKey(name: 'id')
  final String id;

  @js.JsonKey(name: 'username')
  final String username;

  @js.JsonKey(name: 'name')
  final String name;

  @js.JsonKey(name: 'token')
  late String? token;

  @js.JsonKey(name: 'role')
  final String role;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.token,
  });

  Map<String, dynamic> toJson() => _$UserToJson(this);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
