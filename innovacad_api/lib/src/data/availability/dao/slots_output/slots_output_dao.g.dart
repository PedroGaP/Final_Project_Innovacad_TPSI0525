// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slots_output_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlotsOutputDao _$SlotsOutputDaoFromJson(Map<String, dynamic> json) =>
    SlotsOutputDao(
      slotNumber: (json['slot_number'] as num).toInt(),
      startTime: Duration(microseconds: (json['start_time'] as num).toInt()),
      endTime: Duration(microseconds: (json['end_time'] as num).toInt()),
    );

Map<String, dynamic> _$SlotsOutputDaoToJson(SlotsOutputDao instance) =>
    <String, dynamic>{
      'slot_number': instance.slotNumber,
      'start_time': instance.startTime.inMicroseconds,
      'end_time': instance.endTime.inMicroseconds,
    };
