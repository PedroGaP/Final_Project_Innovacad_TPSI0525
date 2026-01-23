// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateRoomDto _$UpdateRoomDtoFromJson(Map<String, dynamic> json) =>
    UpdateRoomDto(
      roomName: json['room_name'] as String?,
      capacity: (json['capacity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateRoomDtoToJson(UpdateRoomDto instance) =>
    <String, dynamic>{
      'room_name': instance.roomName,
      'capacity': instance.capacity,
    };
