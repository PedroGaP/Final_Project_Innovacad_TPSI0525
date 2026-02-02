import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/schedule/dto/auto/auto_schedule_dto.dart';

abstract class IScheduleService {
  Future<Result<List<OutputScheduleDao>>> getAll();
  Future<Result<List<OutputScheduleDao>>> getById(String id);
  Future<Result<List<OutputScheduleDao>>> getByUser(String userId);
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto);
  Future<Result<OutputScheduleDao>> update(String id, UpdateScheduleDto dto);
  Future<Result<OutputScheduleDao>> delete(String id);
  Future<Result<bool>> generateAutomaticSchedule(AutoScheduleDto dto);
}
