import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_simple_schedule_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputSimpleScheduleDao {
  @annotation.JsonKey(name: 'class_module_id')
  final String? classModuleId;

  @annotation.JsonKey(name: 'trainer_id')
  final String? trainerId;

  @annotation.JsonKey(name: 'room_id')
  final int? roomId;

  @annotation.JsonKey(name: 'is_online')
  @NumberConverter()
  final int? isOnline;

  @annotation.JsonKey(name: 'regime_type')
  @NumberConverter()
  final int? regimeType;

  @annotation.JsonKey(name: 'total_hours')
  @DoubleConverter()
  final double? totalHours;

  @annotation.JsonKey(name: 'created_at')
  @DateTimeConverter()
  final DateTime? createdAt;

  OutputSimpleScheduleDao({
    this.classModuleId,
    this.trainerId,
    this.roomId,
    this.isOnline,
    this.regimeType,
    this.totalHours,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => _$OutputSimpleScheduleDaoToJson(this);

  factory OutputSimpleScheduleDao.fromJson(Map<String, dynamic> json) =>
      _$OutputSimpleScheduleDaoFromJson(json);
}
