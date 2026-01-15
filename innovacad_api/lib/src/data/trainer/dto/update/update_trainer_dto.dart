import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_trainer_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateTrainerDto extends UpdateUserDto {
  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime? birthdayDate;

  @annotation.JsonKey(name: 'specialization')
  final String? specialization;

  @annotation.JsonKey(name: 'trainer_id')
  final String trainerId;

  @annotation.JsonKey(name: 'user_id')
  final String userId;

  UpdateTrainerDto({
    required this.trainerId,
    required this.userId,
    this.birthdayDate,
    this.specialization,
    super.name,
    super.password,
  }) : super(id: userId);

  @override
  @annotation.JsonKey(includeToJson: false, includeFromJson: false)
  @Deprecated(
    "We extended the UpdateUserDto class, now the id field can't be called, use the userId field instead.",
  )
  String get id => super.id;

  Map<String, dynamic> toJson() => _$UpdateTrainerDtoToJson(this);

  factory UpdateTrainerDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTrainerDtoFromJson(json);
}
