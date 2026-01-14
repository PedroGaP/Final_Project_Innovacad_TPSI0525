import 'package:innovacad_api/src/domain/dtos/user/user_signup_dto.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'trainer_create_dto.g.dart';

@DTO()
@js.JsonSerializable()
class TrainerCreateDto extends UserSignupDto {
  @js.JsonKey(name: 'birthday_date')
  DateTime birthdayDate;
  @js.JsonKey(name: 'specialization')
  String specialization;

  TrainerCreateDto({
    required super.email,
    required super.name,
    required super.password,
    required super.username,
    required this.birthdayDate,
    required this.specialization,
  });
}
