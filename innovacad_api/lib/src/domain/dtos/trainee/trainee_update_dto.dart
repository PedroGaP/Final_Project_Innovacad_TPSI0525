import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'trainee_update_dto.g.dart';

@DTO()
@js.JsonSerializable()
class TraineeUpdateDto {
  @js.JsonKey(name: 'birthday_date')
  DateTime? birthdayDate;

  TraineeUpdateDto({required this.birthdayDate});

  Map<String, dynamic> toJson() => _$TraineeUpdateDtoToJson(this);
}
