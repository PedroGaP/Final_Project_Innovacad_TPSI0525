import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import "package:innovacad_api/src/core/core.dart";
import 'package:innovacad_api/src/data/data.dart';

part 'output_trainer_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputTrainerDao extends OutputUserDao {
  @annotation.JsonKey(name: 'trainer_id')
  final String trainerId;

  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  @annotation.JsonKey(name: 'specialization')
  final String specialization;

  OutputTrainerDao({
    required super.id,
    required super.createdAt,
    required super.email,
    required super.name,
    required super.username,
    required super.role,
    super.image,
    super.token,
    required this.trainerId,
    required this.birthdayDate,
    required this.specialization,
  });

  Map<String, dynamic> toJson() => _$OutputTrainerDaoToJson(this);

  factory OutputTrainerDao.fromJson(Map<String, dynamic> json) =>
      _$OutputTrainerDaoFromJson(json);
}
