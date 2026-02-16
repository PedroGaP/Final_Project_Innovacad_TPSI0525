// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_public_room_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputPublicRoomDao _$OutputPublicRoomDaoFromJson(Map<String, dynamic> json) =>
    OutputPublicRoomDao(
      roomName: json['room_name'] as String,
      capacity: (json['capacity'] as num).toInt(),
      hasComputers: json['has_computers'] as bool,
      hasProjector: json['has_projector'] as bool,
      hasWhiteboard: json['has_whiteboard'] as bool,
      hasSmartboard: json['has_smartboard'] as bool,
    );

Map<String, dynamic> _$OutputPublicRoomDaoToJson(
  OutputPublicRoomDao instance,
) => <String, dynamic>{
  'room_name': instance.roomName,
  'capacity': instance.capacity,
  'has_computers': instance.hasComputers,
  'has_projector': instance.hasProjector,
  'has_whiteboard': instance.hasWhiteboard,
  'has_smartboard': instance.hasSmartboard,
};
