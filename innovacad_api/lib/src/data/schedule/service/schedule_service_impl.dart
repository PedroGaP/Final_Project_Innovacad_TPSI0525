import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/schedule/dao/output/output_public_schedule_dao.dart';
import 'package:innovacad_api/src/data/schedule/dto/auto/auto_schedule_dto.dart';
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
  Future<Result<List<OutputPublicScheduleDao>>> getAllPublic() async {
    final schedules = await _repository.getAll();

    if (schedules.isFailure) return Result.failure(schedules.error!);

    return Result.success(
      schedules.data!
          .map((s) => OutputPublicScheduleDao.fromJson(s.toJson()))
          .toList(),
    );
  }

  @override
  Future<Result<List<OutputScheduleDao>>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<List<OutputScheduleDao>>> getByUser(String userId) async =>
      await _repository.getByUser(userId);

  @override
  Future<Result<dynamic>> create(CreateScheduleDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputScheduleDao>> update(
    String id,
    UpdateScheduleDto dto,
  ) async => await _repository.update(id, dto);

  @override
  Future<Result<OutputScheduleDao>> delete(String id) async =>
      await _repository.delete(id);

  @override
  Future<Result<bool>> generateAutomaticSchedule(AutoScheduleDto dto) async =>
      await _repository.generateAutomaticSchedule(dto);
}
