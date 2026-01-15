import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_trainee_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateTraineeDto {
  @annotation.JsonKey(name: 'name')
  final String? name;

  @annotation.JsonKey(name: 'username')
  final String? username;

  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime? birthdayDate;

  UpdateTraineeDto({this.name, this.username, this.birthdayDate});

  Map<String, dynamic> toJson() => _$UpdateTraineeDtoToJson(this);

  factory UpdateTraineeDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTraineeDtoFromJson(json);
}
