import 'package:innovacad_api/src/data/user/dao/output/output_public_user_dao.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import "package:innovacad_api/src/core/core.dart";

part 'output_public_trainer_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputPublicTrainerDao extends OutputPublicUserDao {
  @annotation.JsonKey(name: 'trainer_id')
  final String trainerId;

  @annotation.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  @annotation.JsonKey(name: 'is_coordinator')
  final bool? isCoordinator;

  OutputPublicTrainerDao({
    required super.createdAt,
    required super.email,
    required super.name,
    required super.username,
    required super.role,
    required this.trainerId,
    required this.birthdayDate,
    this.isCoordinator,
    super.coordinatedClassIds,
    super.image,
  });

  Map<String, dynamic> toJson() => _$OutputPublicTrainerDaoToJson(this);

  factory OutputPublicTrainerDao.fromJson(Map<String, dynamic> json) =>
      _$OutputPublicTrainerDaoFromJson(json);
}
