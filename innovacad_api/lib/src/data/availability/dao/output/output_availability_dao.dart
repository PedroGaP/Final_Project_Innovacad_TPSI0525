import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'output_availability_dao.g.dart';

@DTO()
@annotation.JsonSerializable()
class OutputAvailabilityDao {
  @annotation.JsonKey(name: 'availability_id')
  final String availabilityId;

  @annotation.JsonKey(name: 'trainer_id')
  final String trainerId;

  @annotation.JsonKey(name: 'date_day')
  @DateTimeConverter()
  final DateTime dateDay;

  @annotation.JsonKey(name: 'slot_number')
  @NumberConverter()
  final int slotNumber;

  @annotation.JsonKey(name: 'is_booked')
  @NumberConverter()
  final int isBooked;

  OutputAvailabilityDao({
    required this.availabilityId,
    required this.trainerId,
    required this.dateDay,
    required this.slotNumber,
    required this.isBooked,
  });

  Map<String, dynamic> toJson() => _$OutputAvailabilityDaoToJson(this);

  factory OutputAvailabilityDao.fromJson(Map<String, dynamic> json) =>
      _$OutputAvailabilityDaoFromJson(json);
}
