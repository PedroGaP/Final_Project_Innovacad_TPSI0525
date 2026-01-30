import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_trainer_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class CreateTrainerDto extends CreateUserDto
    with vaden.Validator<CreateTrainerDto> {
  @vaden.JsonKey('birthday_date')
  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  @annotation.JsonKey(name: 'skills_to_add')
  @vaden.JsonKey('skills_to_add')
  final List<TrainerSkillDto>? skillsToAdd;

  CreateTrainerDto({
    required super.name,
    required super.email,
    required super.username,
    required super.password,
    required this.birthdayDate,
    this.skillsToAdd,
  });

  Map<String, dynamic> toJson() => _$CreateTrainerDtoToJson(this);

  factory CreateTrainerDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTrainerDtoFromJson(json);

  @override
  vaden.LucidValidator<CreateTrainerDto> validate(
    vaden.ValidatorBuilder<CreateTrainerDto> builder,
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
