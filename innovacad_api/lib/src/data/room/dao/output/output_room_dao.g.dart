// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_room_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputRoomDao _$OutputRoomDaoFromJson(Map<String, dynamic> json) =>
    OutputRoomDao(
      roomId: (json['room_id'] as num).toInt(),
      roomName: json['room_name'] as String,
      capacity: (json['capacity'] as num).toInt(),
      hasComputers: json['has_computers'] as bool,
      hasProjector: json['has_projector'] as bool,
      hasWhiteboard: json['has_whiteboard'] as bool,
      hasSmartboard: json['has_smartboard'] as bool,
    );

Map<String, dynamic> _$OutputRoomDaoToJson(OutputRoomDao instance) =>
    <String, dynamic>{
      'room_id': instance.roomId,
      'room_name': instance.roomName,
      'capacity': instance.capacity,
      'has_computers': instance.hasComputers,
      'has_projector': instance.hasProjector,
      'has_whiteboard': instance.hasWhiteboard,
      'has_smartboard': instance.hasSmartboard,
    };
