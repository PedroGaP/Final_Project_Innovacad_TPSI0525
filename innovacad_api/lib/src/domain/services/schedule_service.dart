import 'package:innovacad_api/src/domain/dtos/schedule/schedule_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/schedule/schedule_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/schedule.dart';

abstract interface class IScheduleService {
  Future<List<Schedule>?> getAll();
  Future<Schedule?> getById(String id);
  Future<Schedule?> create(ScheduleCreateDto dto);
  Future<Schedule?> update(ScheduleUpdateDto dto);
  Future<Schedule?> delete(String id);
}
