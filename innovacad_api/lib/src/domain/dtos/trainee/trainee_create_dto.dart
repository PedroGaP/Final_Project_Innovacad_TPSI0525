import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trainee_create_dto.g.dart';

@DTO()
@JsonSerializable()
class TraineeCreateDto {
  String first_name;
  String last_name;
  DateTime birthday_date;

  TraineeCreateDto({
    required this.first_name,
    required this.last_name,
    required this.birthday_date,
  });

  Map<String, dynamic> toJson() => _$TraineeCreateDtoToJson(this);
}
