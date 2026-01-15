import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/schedule/service/i_schedule_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Schedules", description: "CRUD for schedules")
@Controller("/schedules")
class ScheduleController {
  final IScheduleService _service;

  ScheduleController(this._service);

  @Get('/')
  Future<Response> getAll() async {
    final result = await _service.getAll();
    return resultToResponse(result);
  }

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    final result = await _service.getById(id);
    return resultToResponse(result);
  }

  @Post("/")
  Future<Response> create(@Body() CreateScheduleDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateScheduleDto dto,
  ) async {
    if (dto.scheduleId != id) {
       // Validate
    }
    final result = await _service.update(dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(
    @Param("id") String id,
    @Body() DeleteScheduleDto dto 
  ) async {
      final result = await _service.delete(dto);
      return resultToResponse(result);
  }
}
