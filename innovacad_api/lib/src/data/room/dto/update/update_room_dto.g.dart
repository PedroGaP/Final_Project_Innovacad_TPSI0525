// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateRoomDto _$UpdateRoomDtoFromJson(Map<String, dynamic> json) =>
    UpdateRoomDto(
      roomName: json['room_name'] as String?,
      capacity: (json['capacity'] as num?)?.toInt(),
      hasComputers: json['has_computers'] as bool?,
      hasProjector: json['has_projector'] as bool?,
      hasWhiteboard: json['has_whiteboard'] as bool?,
      hasSmartboard: json['has_smartboard'] as bool?,
    );

Map<String, dynamic> _$UpdateRoomDtoToJson(UpdateRoomDto instance) =>
    <String, dynamic>{
      'room_name': instance.roomName,
      'capacity': instance.capacity,
      'has_computers': instance.hasComputers,
      'has_projector': instance.hasProjector,
      'has_whiteboard': instance.hasWhiteboard,
      'has_smartboard': instance.hasSmartboard,
    };
