import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_trainee_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateTraineeDto extends UpdateUserDto with Validator<UpdateTraineeDto> {
  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime? birthdayDate;

  UpdateTraineeDto({super.name, this.birthdayDate});

  @override
  LucidValidator<UpdateTraineeDto> validate(
    ValidatorBuilder<UpdateTraineeDto> builder,
  ) {
    if (birthdayDate != null) {
      final now = DateTime.now();
      final minAgeDate = DateTime(now.year - 13, now.month, now.day);

      builder
          .ruleFor((e) => e.birthdayDate, key: 'birthday_date')
          .lessThanOrEqualTo(now, message: 'Birthday cannot be in the future')
          .lessThanOrEqualTo(
            minAgeDate,
            message: 'You must be at least 13 years old',
          );
    }
    return builder;
  }

  Map<String, dynamic> toJson() => _$UpdateTraineeDtoToJson(this);

  factory UpdateTraineeDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTraineeDtoFromJson(json);
}
