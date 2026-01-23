import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_room_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputRoomDao {
  @annotation.JsonKey(name: 'room_id')
  final int roomId;

  @annotation.JsonKey(name: 'room_name')
  final String roomName;

  @annotation.JsonKey(name: 'capacity')
  final int capacity;

  @annotation.JsonKey(name: 'has_computers')
  final bool hasComputers;

  @annotation.JsonKey(name: 'has_projector')
  final bool hasProjector;

  @annotation.JsonKey(name: 'has_whiteboard')
  final bool hasWhiteboard;

  @annotation.JsonKey(name: 'has_smartboard')
  final bool hasSmartboard;

  OutputRoomDao({
    required this.roomId,
    required this.roomName,
    required this.capacity,
    required this.hasComputers,
    required this.hasProjector,
    required this.hasWhiteboard,
    required this.hasSmartboard,
  });

  Map<String, dynamic> toJson() => _$OutputRoomDaoToJson(this);

  factory OutputRoomDao.fromJson(Map<String, dynamic> json) =>
      _$OutputRoomDaoFromJson(json);
}
