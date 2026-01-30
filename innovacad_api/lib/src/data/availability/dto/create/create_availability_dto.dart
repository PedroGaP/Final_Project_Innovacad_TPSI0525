import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'create_availability_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class CreateAvailabilityDto {
  @annotation.JsonKey(name: 'trainer_id')
  @vaden.JsonKey('trainer_id')
  final String trainerId;

  @annotation.JsonKey(name: 'date_day')
  @vaden.JsonKey('date_day')
  @DateTimeConverter()
  final DateTime dateDay;

  @annotation.JsonKey(name: 'slot_number')
  @vaden.JsonKey('slot_number')
  final int slotNumber;

  @annotation.JsonKey(name: 'is_booked')
  @vaden.JsonKey('is_booked')
  final int isBooked;

  CreateAvailabilityDto({
    required this.trainerId,
    required this.dateDay,
    required this.slotNumber,
    required this.isBooked,
  });

  Map<String, dynamic> toJson() => _$CreateAvailabilityDtoToJson(this);

  factory CreateAvailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAvailabilityDtoFromJson(json);
}
