import 'package:innovacad_api/src/core/core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'output_room_busy_dao.g.dart';

@JsonSerializable()
class OutputRoomBusyDao {
  @JsonKey(name: 'schedule_id')
  final String scheduleId;

  @JsonKey(name: 'start_time')
  @DateTimeConverter()
  final DateTime startTime;

  @JsonKey(name: 'end_time')
  @DateTimeConverter()
  final DateTime endTime;

  @JsonKey(name: 'module_name')
  final String? moduleName;

  OutputRoomBusyDao({
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
    this.moduleName,
  });

  Map<String, dynamic> toJson() => _$OutputRoomBusyDaoToJson(this);

  factory OutputRoomBusyDao.fromJson(Map<String, dynamic> json) =>
      _$OutputRoomBusyDaoFromJson(json);
}
