import 'package:innovacad_api/src/domain/dtos/schedule/schedule_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/schedule/schedule_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/schedule.dart';
import 'package:innovacad_api/src/domain/repositories/schedule_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ScheduleRepositoryImpl implements IScheduleRepository {
  @override
  Future<List<Schedule>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<Schedule?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Schedule?> create(ScheduleCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Schedule?> update(ScheduleUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Schedule?> delete(String id) {
    throw UnimplementedError();
  }
}
