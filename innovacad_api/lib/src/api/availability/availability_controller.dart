import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Availabilities", description: "CRUD for availabilities")
@Controller("/availabilities")
class AvailabilityController {
  final IAvailabilityService _service;

  AvailabilityController(this._service);

  @Get('/')
  Future<Response> getAll() async {
    return resultToResponse(await _service.getAll());
  }

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    return resultToResponse(await _service.getById(id));
  }

  @Post("/")
  Future<Response> create(@Body() CreateAvailabilityDto dto) async {
    return resultToResponse(await _service.create(dto));
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateAvailabilityDto dto,
  ) async {
    return resultToResponse(await _service.update(id, dto));
  }

  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async {
    return resultToResponse(await _service.delete(id));
  }
}
