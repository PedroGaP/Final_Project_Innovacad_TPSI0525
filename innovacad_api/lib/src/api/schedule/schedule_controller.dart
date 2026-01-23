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
    return resultToResponse(await _service.getAll());
  }

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    return resultToResponse(await _service.getById(id));
  }

  @Post("/")
  Future<Response> create(@Body() CreateScheduleDto dto) async {
    return resultToResponse(await _service.create(dto));
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateScheduleDto dto,
  ) async {
    return resultToResponse(await _service.update(id, dto));
  }

  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async {
    return resultToResponse(await _service.delete(id));
  }
}
