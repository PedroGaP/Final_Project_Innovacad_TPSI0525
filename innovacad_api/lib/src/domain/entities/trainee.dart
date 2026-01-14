import 'package:innovacad_api/src/domain/converters/date_time_converter.dart';
import 'package:innovacad_api/src/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'trainee.g.dart';

@js.JsonSerializable()
class Trainee extends User {
  @js.JsonKey(name: "trainee_id")
  String traineeId;

  @DateTimeConverter()
  @js.JsonKey(name: "birthday_date")
  DateTime birthdayDate;

  Trainee({
    required super.id,
    required super.username,
    required super.name,
    required super.role,
    required this.traineeId,
    required this.birthdayDate,
    super.token,
  });

  factory Trainee.fromJson(Map<String, dynamic> json) =>
      _$TraineeFromJson(json);

  Map<String, dynamic> toJson() => _$TraineeToJson(this);
}
