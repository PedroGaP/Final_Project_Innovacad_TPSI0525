import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_room_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class CreateRoomDto {
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

  CreateRoomDto({
    required this.roomName,
    required this.capacity,
    required this.hasComputers,
    required this.hasProjector,
    required this.hasWhiteboard,
    required this.hasSmartboard,
  });

  Map<String, dynamic> toJson() => _$CreateRoomDtoToJson(this);

  factory CreateRoomDto.fromJson(Map<String, dynamic> json) =>
      _$CreateRoomDtoFromJson(json);
}
