import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/schedule/repository/i_schedule_repository.dart';
import 'package:innovacad_api/src/domain/schedule/service/i_schedule_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class ScheduleServiceImpl implements IScheduleService {
  final IScheduleRepository _repository;

  ScheduleServiceImpl(this._repository);

  @override
  Future<Result<List<OutputScheduleDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<OutputScheduleDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputScheduleDao>> update(
    String id,
    UpdateScheduleDto dto,
  ) async => await _repository.update(id, dto);

  @override
  Future<Result<OutputScheduleDao>> delete(String id) async =>
      await _repository.delete(id);
}
