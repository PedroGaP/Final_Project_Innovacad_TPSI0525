import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_room_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputRoomDao {
  @annotation.JsonKey(name: 'room_id')
  final int roomId; // Keeping int as per old entity, but will verification if String is needed.

  @annotation.JsonKey(name: 'room_name')
  final String roomName;

  @annotation.JsonKey(name: 'capacity')
  final int capacity;

  OutputRoomDao({
    required this.roomId,
    required this.roomName,
    required this.capacity,
  });

  Map<String, dynamic> toJson() => _$OutputRoomDaoToJson(this);

  factory OutputRoomDao.fromJson(Map<String, dynamic> json) =>
      _$OutputRoomDaoFromJson(json);
}
