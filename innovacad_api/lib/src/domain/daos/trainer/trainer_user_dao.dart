import 'package:innovacad_api/src/domain/converters/date_time_converter.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as js;

part 'trainer_user_dao.g.dart';

@Component()
@js.JsonSerializable()
class TrainerUserDao {
  @js.JsonKey(name: 'id')
  final String userId;

  @js.JsonKey(name: 'trainer_id')
  final String traineeId;

  @js.JsonKey(name: 'email')
  final String email;

  @js.JsonKey(name: 'name')
  final String name;

  @js.JsonKey(name: 'username')
  final String username;

  @js.JsonKey(name: 'createdAt')
  @DateTimeConverter()
  final DateTime createdAt;

  @js.JsonKey(name: 'birthday_date')
  @DateTimeConverter()
  final DateTime birthdayDate;

  @js.JsonKey(name: 'specialization')
  String specialization;

  @js.JsonKey(name: 'token')
  final String token;

  @js.JsonKey(name: 'role')
  final String role;

  @js.JsonKey(name: 'image')
  final String? image;

  TrainerUserDao({
    required this.userId,
    required this.traineeId,
    required this.username,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.birthdayDate,
    required this.specialization,
    required this.token,
    required this.role,
    this.image,
  });

  Map<String, dynamic> toJson() => _$TrainerUserDaoToJson(this);
  factory TrainerUserDao.fromJson(Map<String, dynamic> json) =>
      _$TrainerUserDaoFromJson(json);
}
