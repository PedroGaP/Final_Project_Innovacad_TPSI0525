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

  @annotation.JsonKey(name: 'status')
  final String status;

  @annotation.JsonKey(name: 'start_date_timestamp')
  @DateTimeConverter()
  final DateTime startDateTimestamp;

  @annotation.JsonKey(name: 'end_date_timestamp')
  @DateTimeConverter()
  final DateTime endDateTimestamp;

  OutputAvailabilityDao({
    required this.availabilityId,
    required this.trainerId,
    required this.status,
    required this.startDateTimestamp,
    required this.endDateTimestamp,
  });

  Map<String, dynamic> toJson() => _$OutputAvailabilityDaoToJson(this);

  factory OutputAvailabilityDao.fromJson(Map<String, dynamic> json) =>
      _$OutputAvailabilityDaoFromJson(json);
}
