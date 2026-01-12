import 'package:innovacad_api/src/domain/converters/date_time_converter.dart';
import 'package:innovacad_api/src/domain/entities/user.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'trainer.g.dart';

@Component()
@js.JsonSerializable()
class Trainer extends User {
  @js.JsonKey(name: 'trainer_id')
  String trainerId;

  @DateTimeConverter()
  @js.JsonKey(name: 'birthday_date')
  DateTime birthdayDate;

  Trainer({
    required super.id,
    required super.username,
    required super.name,
    required this.trainerId,
    required this.birthdayDate,
  });

  Map<String, dynamic> toJson() => _$TrainerToJson(this);
  factory Trainer.fromJson(Map<String, dynamic> json) =>
      _$TrainerFromJson(json);
}
