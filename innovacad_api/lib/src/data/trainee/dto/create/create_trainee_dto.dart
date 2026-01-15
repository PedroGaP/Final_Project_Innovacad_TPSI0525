import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_trainee_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateTraineeDto {
  @annotation.JsonKey(name: 'email')
  final String email;

  @annotation.JsonKey(name: 'username')
  final String username;

  @annotation.JsonKey(name: 'name')
  final String name;

  @annotation.JsonKey(name: 'password')
  final String password;

  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  CreateTraineeDto({
    required this.email,
    required this.username,
    required this.name,
    required this.password,
    required this.birthdayDate,
  });

  Map<String, dynamic> toJson() => _$CreateTraineeDtoToJson(this);

  factory CreateTraineeDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTraineeDtoFromJson(json);
}
