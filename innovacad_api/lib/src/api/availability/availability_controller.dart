import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/availability/service/i_availability_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Availabilities", description: "CRUD for availabilities")
@Controller("/availabilities")
class AvailabilityController {
  final IAvailabilityService _service;

  AvailabilityController(this._service);

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
  Future<Response> create(@Body() CreateAvailabilityDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateAvailabilityDto dto,
  ) async {
    if (dto.availabilityId != id) {
       // Validate
    }
    final result = await _service.update(dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(
    @Param("id") String id,
    @Body() DeleteAvailabilityDto dto 
  ) async {
      final result = await _service.delete(dto);
      return resultToResponse(result);
  }
}
