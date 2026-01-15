import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_room_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateRoomDto {
  @annotation.JsonKey(name: 'room_id')
  final int roomId;

  @annotation.JsonKey(name: 'room_name')
  final String? roomName;

  @annotation.JsonKey(name: 'capacity')
  final int? capacity;

  UpdateRoomDto({
    required this.roomId,
    this.roomName, // Optional
    this.capacity,
  });

  Map<String, dynamic> toJson() => _$UpdateRoomDtoToJson(this);

  factory UpdateRoomDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateRoomDtoFromJson(json);
}
