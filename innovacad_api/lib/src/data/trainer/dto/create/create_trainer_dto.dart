import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_trainer_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateTrainerDto extends CreateUserDto with Validator<CreateTrainerDto> {
  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  @annotation.JsonKey(name: 'specialization')
  final String specialization;

  CreateTrainerDto({
    required super.name,
    required super.email,
    required super.username,
    required super.password,
    required this.birthdayDate,
    required this.specialization,
  });

  Map<String, dynamic> toJson() => _$CreateTrainerDtoToJson(this);

  factory CreateTrainerDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTrainerDtoFromJson(json);

  @override
  LucidValidator<CreateTrainerDto> validate(
    ValidatorBuilder<CreateTrainerDto> builder,
  ) {
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
    return builder;
  }
}
