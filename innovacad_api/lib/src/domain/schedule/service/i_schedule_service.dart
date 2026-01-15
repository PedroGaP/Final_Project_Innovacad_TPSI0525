import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/schedule/dao/output/output_schedule_dao.dart';
import 'package:innovacad_api/src/data/schedule/dto/create/create_schedule_dto.dart';
import 'package:innovacad_api/src/data/schedule/dto/delete/delete_schedule_dto.dart';
import 'package:innovacad_api/src/data/schedule/dto/update/update_schedule_dto.dart';

abstract class IScheduleService {
  Future<Result<List<OutputScheduleDao>>> getAll();
  Future<Result<OutputScheduleDao>> getById(String id);
  Future<Result<OutputScheduleDao>> create(CreateScheduleDto dto);
  Future<Result<OutputScheduleDao>> update(UpdateScheduleDto dto);
  Future<Result<OutputScheduleDao>> delete(DeleteScheduleDto dto);
}
