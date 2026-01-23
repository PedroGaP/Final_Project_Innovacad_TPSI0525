import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_room_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class UpdateRoomDto {
  @annotation.JsonKey(name: 'room_name')
  final String? roomName;

  @annotation.JsonKey(name: 'capacity')
  final int? capacity;

  @annotation.JsonKey(name: 'has_computers')
  final bool? hasComputers;

  @annotation.JsonKey(name: 'has_projector')
  final bool? hasProjector;

  @annotation.JsonKey(name: 'has_whiteboard')
  final bool? hasWhiteboard;

  @annotation.JsonKey(name: 'has_smartboard')
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
