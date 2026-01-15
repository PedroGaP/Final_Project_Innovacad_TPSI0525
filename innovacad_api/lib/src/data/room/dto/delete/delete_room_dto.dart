import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_room_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteRoomDto {
  @annotation.JsonKey(name: 'room_id')
  final int roomId;

  DeleteRoomDto({required this.roomId});

  Map<String, dynamic> toJson() => _$DeleteRoomDtoToJson(this);

  factory DeleteRoomDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteRoomDtoFromJson(json);
}
