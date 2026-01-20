import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_user_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateUserDto {
  @annotation.JsonKey(name: 'name')
  final String? name;

  @annotation.JsonKey(name: 'image')
  final String? image;

  UpdateUserDto({this.name, this.image});

  Map<String, dynamic> toJson() => _$UpdateUserDtoToJson(this);

  factory UpdateUserDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserDtoFromJson(json);
}
