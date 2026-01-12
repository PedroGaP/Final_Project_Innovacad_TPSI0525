import 'package:innovacad_api/src/data/repositories/schedule_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/schedule/schedule_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/schedule/schedule_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/schedule.dart';
import 'package:innovacad_api/src/domain/services/schedule_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class ScheduleServiceImpl implements IScheduleService {
  final ScheduleRepositoryImpl _repository;

  ScheduleServiceImpl(this._repository);

  @override
  Future<List<Schedule>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Schedule?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Schedule?> create(ScheduleCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Schedule?> update(ScheduleUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Schedule?> delete(String id) async {
    return await _repository.delete(id);
  }
}
