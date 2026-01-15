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
  Future<Result<List<OutputScheduleDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputScheduleDao>> getById(String id) async => _repository.getById(id);

  @override
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto) async => _repository.create(dto);

  @override
  Future<Result<OutputScheduleDao>> update(UpdateScheduleDto dto) async => _repository.update(dto);

  @override
  Future<Result<OutputScheduleDao>> delete(DeleteScheduleDto dto) async => _repository.delete(dto);
}
