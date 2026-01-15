import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_trainer_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateTrainerDto extends CreateUserDto {
  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  @annotation.JsonKey(name: 'specialization')
  final String specialization;

  CreateTrainerDto({
    required this.birthdayDate,
    required this.specialization,
    required super.name,
    required super.email,
    required super.username,
    required super.password,
  });

  Map<String, dynamic> toJson() => _$CreateTrainerDtoToJson(this);

  factory CreateTrainerDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTrainerDtoFromJson(json);
}
