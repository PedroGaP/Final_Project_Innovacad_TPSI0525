// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateRoomDto _$CreateRoomDtoFromJson(Map<String, dynamic> json) =>
    CreateRoomDto(
      roomName: json['room_name'] as String,
      capacity: (json['capacity'] as num).toInt(),
    );

Map<String, dynamic> _$CreateRoomDtoToJson(CreateRoomDto instance) =>
    <String, dynamic>{
      'room_name': instance.roomName,
      'capacity': instance.capacity,
    };
