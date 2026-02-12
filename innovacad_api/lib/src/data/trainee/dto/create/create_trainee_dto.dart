import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_trainee_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateTraineeDto extends CreateUserDto with Validator<CreateTraineeDto> {
  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  CreateTraineeDto({
    required super.name,
    required super.email,
    required super.username,
    required super.password,
    required this.birthdayDate,
  });

  @override
  LucidValidator<CreateTraineeDto> validate(
    ValidatorBuilder<CreateTraineeDto> builder,
  ) {
    final now = DateTime.now();
    final minAgeDate = DateTime(now.year - 13, now.month, now.day);

    builder.ruleFor((e) => e.email, key: 'email').notEmptyOrNull().validEmail();
    builder
        .ruleFor((e) => e.password, key: 'password')
        .notEmptyOrNull()
        .mustHaveSpecialCharacter()
        .mustHaveUppercase()
        .minLength(8);
    builder
        .ruleFor((e) => e.username, key: 'username')
        .notEmptyOrNull()
        .minLength(4);
    builder
        .ruleFor((e) => e.birthdayDate, key: 'birthday_date')
        .lessThanOrEqualTo(now, message: 'Birthday cannot be in the future')
        .lessThanOrEqualTo(
          minAgeDate,
          message: 'You must be at least 13 years old',
        );
    return builder;
  }

  Map<String, dynamic> toJson() => _$CreateTraineeDtoToJson(this);

  factory CreateTraineeDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTraineeDtoFromJson(json);
}
