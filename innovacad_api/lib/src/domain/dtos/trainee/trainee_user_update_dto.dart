import 'package:innovacad_api/src/domain/converters/date_time_converter.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'trainee_user_update_dto.g.dart';

@DTO()
@js.JsonSerializable()
class TraineeUserUpdateDto {
  @js.JsonKey(name: 'name')
  final String? name;

  @js.JsonKey(name: 'image')
  final String? image;

  @js.JsonKey(name: 'role')
  final String? role;

  @js.JsonKey(name: 'username')
  final String? username;

  @js.JsonKey(name: 'email')
  final String? email;

  @dateTimePreserveConverter
  @js.JsonKey(name: 'birthday_date')
  final DateTime? birthdayDate;

  TraineeUserUpdateDto({
    this.name,
    this.image,
    this.role,
    this.username,
    this.email,
    this.birthdayDate,
  });

  Map<String, dynamic> toJson() => _$TraineeUserUpdateDtoToJson(this);
  factory TraineeUserUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$TraineeUserUpdateDtoFromJson(json);
}
