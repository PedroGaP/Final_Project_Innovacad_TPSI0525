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

  @annotation.JsonKey(name: 'user_id')
  final String userId;

  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  @annotation.JsonKey(name: 'specialization')
  final String specialization;

  OutputTrainerDao({
    required this.trainerId,
    required this.userId,
    required this.birthdayDate,
    required this.specialization,
    required super.name,
    required super.email,
    required super.username,
    required super.role,
    required super.createdAt,
    super.token,
    super.image,
  }) : super(id: userId);

  @override
  @annotation.JsonKey(includeToJson: false, includeFromJson: false)
  @Deprecated(
    "We extended the OutputUserDao class, now the id field can't be called, use the userId field instead.",
  )
  String get id => super.id;

  Map<String, dynamic> toJson() => _$OutputTrainerDaoToJson(this);

  factory OutputTrainerDao.fromJson(Map<String, dynamic> json) =>
      _$OutputTrainerDaoFromJson(json);
}
