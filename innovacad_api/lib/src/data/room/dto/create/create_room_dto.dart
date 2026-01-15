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

  CreateRoomDto({required this.roomName, required this.capacity});

  Map<String, dynamic> toJson() => _$CreateRoomDtoToJson(this);

  factory CreateRoomDto.fromJson(Map<String, dynamic> json) =>
      _$CreateRoomDtoFromJson(json);
}
