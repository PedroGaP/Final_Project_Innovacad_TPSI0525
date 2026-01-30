import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'slots_output_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class SlotsOutputDao {
  @annotation.JsonKey(name: 'slot_number')
  final int slotNumber;

  @annotation.JsonKey(name: 'start_time')
  final Duration startTime;

  @annotation.JsonKey(name: 'end_time')
  final Duration endTime;

  SlotsOutputDao({
    required this.slotNumber,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => _$SlotsOutputDaoToJson(this);

  factory SlotsOutputDao.fromJson(Map<String, dynamic> json) =>
      _$SlotsOutputDaoFromJson(json);
}
