import 'package:innovacad_api/src/domain/dtos/user/user_signup_dto.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'trainee_create_dto.g.dart';

@DTO()
@js.JsonSerializable()
class TraineeCreateDto extends UserSignupDto with Validator<TraineeCreateDto> {
  @js.JsonKey(name: 'birthday_date')
  DateTime birthdayDate;

  TraineeCreateDto({
    required super.email,
    required super.name,
    required super.password,
    required super.username,
    required this.birthdayDate,
  });

  @override
  LucidValidator<TraineeCreateDto> validate(
    ValidatorBuilder<TraineeCreateDto> builder,
  ) {
    builder.ruleFor((c) => c.email, key: 'email').notEmpty().validEmail();
    builder.ruleFor((c) => c.password, key: 'password').notEmpty().minLength(8);
    return builder;
  }

  Map<String, dynamic> toJson() => _$TraineeCreateDtoToJson(this);
}
