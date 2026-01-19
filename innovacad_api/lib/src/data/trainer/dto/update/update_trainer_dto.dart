import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_trainer_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateTrainerDto extends UpdateUserDto with Validator<UpdateTraineeDto> {
  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime? birthdayDate;

  @annotation.JsonKey(name: 'specialization')
  final String? specialization;

  UpdateTrainerDto({
    super.name,
    super.oldPassword,
    super.newPassword,
    super.image,
    super.sessionToken,
    this.birthdayDate,
    this.specialization,
  });

  @override
  LucidValidator<UpdateTraineeDto> validate(
    ValidatorBuilder<UpdateTraineeDto> builder,
  ) {
    return builder;
  }

  Map<String, dynamic> toJson() => _$UpdateTrainerDtoToJson(this);

  factory UpdateTrainerDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTrainerDtoFromJson(json);
}
