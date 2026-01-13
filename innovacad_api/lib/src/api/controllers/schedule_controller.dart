import 'package:innovacad_api/src/domain/dtos/schedule/schedule_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/schedule/schedule_update_dto.dart';
import 'package:innovacad_api/src/data/services/schedule_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Schedules", description: "CRUD for schedules")
@Controller("/schedules")
class ScheduleController {
  final ScheduleServiceImpl _service;

  ScheduleController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() ScheduleCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() ScheduleUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
