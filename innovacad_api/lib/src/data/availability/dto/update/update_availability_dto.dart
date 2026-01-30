import 'package:innovacad_api/src/core/core.dart';
import 'package:vaden/vaden.dart' as vaden;
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'update_availability_dto.g.dart';

@vaden.DTO()
@annotation.JsonSerializable()
class UpdateAvailabilityDto {
  @annotation.JsonKey(name: 'trainer_id')
  @vaden.JsonKey('trainer_id')
  final String? trainerId;

  @annotation.JsonKey(name: 'date_day')
  @vaden.JsonKey('date_day')
  @DateTimeConverter()
  final DateTime? dateDay;

  @annotation.JsonKey(name: 'slot_number')
  @vaden.JsonKey('slot_number')
  final int? slotNumber;

  @annotation.JsonKey(name: 'is_booked')
  @vaden.JsonKey('is_booked')
  final int? isBooked;

  UpdateAvailabilityDto({
    this.trainerId,
    this.dateDay,
    this.slotNumber,
    this.isBooked,
  });

  Map<String, dynamic> toJson() => _$UpdateAvailabilityDtoToJson(this);

  factory UpdateAvailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateAvailabilityDtoFromJson(json);
}
