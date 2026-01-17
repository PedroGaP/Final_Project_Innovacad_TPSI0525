import 'package:vaden/vaden.dart';
// import 'package:json_annotation/json_annotation.dart' as annotation;

@DTO()
// @annotation.JsonSerializable()
class UserLinkAccountDto {
  // @annotation.JsonKey(name: "id")
  final String provider;
  final String callback;

  UserLinkAccountDto({required this.provider, required this.callback});
}
