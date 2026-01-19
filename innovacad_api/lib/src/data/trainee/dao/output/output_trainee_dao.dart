import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_trainee_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputTraineeDao extends OutputUserDao {
  @annotation.JsonKey(name: 'trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  OutputTraineeDao({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    required super.role,
    required super.createdAt,
    required super.verified,
    required this.traineeId,
    required this.birthdayDate,
    super.token,
    super.image,
    super.sessionToken,
  });

  Map<String, dynamic> toJson() => _$OutputTraineeDaoToJson(this);

  factory OutputTraineeDao.fromJson(Map<String, dynamic> json) =>
      _$OutputTraineeDaoFromJson(json);
}
