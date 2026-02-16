import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/user/dao/output/output_public_user_dao.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_public_trainee_dao.g.dart';

@annotation.JsonSerializable()
class OutputPublicTraineeDao extends OutputPublicUserDao {
  @annotation.JsonKey(name: 'trainee_id')
  final String traineeId;

  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  OutputPublicTraineeDao({
    required super.username,
    required super.name,
    required super.email,
    required super.role,
    required super.createdAt,
    required this.traineeId,
    required this.birthdayDate,
  });

  Map<String, dynamic> toJson() => _$OutputPublicTraineeDaoToJson(this);

  factory OutputPublicTraineeDao.fromJson(Map<String, dynamic> json) =>
      _$OutputPublicTraineeDaoFromJson(json);
}
