import 'package:vaden/vaden.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'delete_availability_dto.g.dart';

@DTO()
@annotation.JsonSerializable()
class DeleteAvailabilityDto {
  @annotation.JsonKey(name: 'availability_id')
  final String availabilityId;

  DeleteAvailabilityDto({required this.availabilityId});

  Map<String, dynamic> toJson() => _$DeleteAvailabilityDtoToJson(this);

  factory DeleteAvailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteAvailabilityDtoFromJson(json);
}
