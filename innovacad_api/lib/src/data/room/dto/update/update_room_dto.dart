import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_room_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class UpdateRoomDto {
  @annotation.JsonKey(name: 'room_name')
  @vaden.JsonKey('room_name')
  final String? roomName;

  @annotation.JsonKey(name: 'capacity')
  final int? capacity;

  @annotation.JsonKey(name: 'has_computers')
  @vaden.JsonKey('has_computers')
  final bool? hasComputers;

  @annotation.JsonKey(name: 'has_projector')
  @vaden.JsonKey('has_projector')
  final bool? hasProjector;

  @annotation.JsonKey(name: 'has_whiteboard')
  @vaden.JsonKey('has_whiteboard')
  final bool? hasWhiteboard;

  @annotation.JsonKey(name: 'has_smartboard')
  @vaden.JsonKey('has_smartboard')
  final bool? hasSmartboard;

  UpdateRoomDto({
    this.roomName,
    this.capacity,
    this.hasComputers,
    this.hasProjector,
    this.hasWhiteboard,
    this.hasSmartboard,
  });

  Map<String, dynamic> toJson() => _$UpdateRoomDtoToJson(this);

  factory UpdateRoomDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateRoomDtoFromJson(json);
}
