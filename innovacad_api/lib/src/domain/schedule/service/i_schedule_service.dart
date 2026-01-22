import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IScheduleService {
  Future<Result<List<OutputScheduleDao>>> getAll();
  Future<Result<OutputScheduleDao>> getById(String id);
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto);
  Future<Result<OutputScheduleDao>> update(String id, UpdateScheduleDto dto);
  Future<Result<OutputScheduleDao>> delete(String id);
}
