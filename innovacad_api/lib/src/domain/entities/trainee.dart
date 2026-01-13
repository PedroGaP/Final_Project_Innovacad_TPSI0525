import 'package:innovacad_api/src/domain/converters/date_time_converter.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trainee.g.dart';

@Component()
@JsonSerializable()
class Trainee {
  String trainee_id;
  String user_id;

  @DateTimeConverter()
  DateTime birthday_date;

  Trainee({
    required this.trainee_id,
    required this.user_id,
    required this.birthday_date,
  });

  factory Trainee.fromJson(Map<String, dynamic> json) =>
      _$TraineeFromJson(json);

  Map<String, dynamic> toJson() => _$TraineeToJson(this);
}
