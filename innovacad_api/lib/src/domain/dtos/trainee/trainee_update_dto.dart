import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trainee_update_dto.g.dart';

@DTO()
@JsonSerializable()
class TraineeUpdateDto {
  String? user_id;
  DateTime? birthday_date;

  TraineeUpdateDto({required this.user_id, required this.birthday_date});

  Map<String, dynamic> toJson() => _$TraineeUpdateDtoToJson(this);
}
