import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_trainer_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class UpdateTrainerDto extends UpdateUserDto
    with vaden.Validator<UpdateTraineeDto> {
  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime? birthdayDate;

  @annotation.JsonKey(name: 'skills_to_add')
  @vaden.JsonKey('skills_to_add')
  final List<TrainerSkillDto>? skillsToAdd;

  @annotation.JsonKey(name: 'skills_to_remove')
  @vaden.JsonKey('skills_to_remove')
  final String? skillsToRemove;

  UpdateTrainerDto({
    super.name,
    super.image,
    this.birthdayDate,
    this.skillsToAdd,
    this.skillsToRemove,
  });

  @override
  vaden.LucidValidator<UpdateTraineeDto> validate(
    vaden.ValidatorBuilder<UpdateTraineeDto> builder,
  ) {
    return builder;
  }

  Map<String, dynamic> toJson() => _$UpdateTrainerDtoToJson(this);

  factory UpdateTrainerDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTrainerDtoFromJson(json);
}
