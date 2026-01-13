import 'package:innovacad_api/src/domain/dtos/availability/availability_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/availability/availability_update_dto.dart';
import 'package:innovacad_api/src/data/services/availability_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Availabilities", description: "CRUD for trainer availabilities")
@Controller("/availabilities")
class AvailabilityController {
  final AvailabilityServiceImpl _service;

  AvailabilityController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() AvailabilityCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() AvailabilityUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
