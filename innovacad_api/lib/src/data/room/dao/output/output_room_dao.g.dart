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
    );

Map<String, dynamic> _$OutputRoomDaoToJson(OutputRoomDao instance) =>
    <String, dynamic>{
      'room_id': instance.roomId,
      'room_name': instance.roomName,
      'capacity': instance.capacity,
    };
