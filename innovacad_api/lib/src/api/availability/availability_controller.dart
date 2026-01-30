import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Availabilities", description: "CRUD for availabilities")
@Controller("/availabilities")
class AvailabilityController {
  final IAvailabilityService _service;

  AvailabilityController(this._service);

  @ApiOperation(
    summary: 'Get all availabilities',
    description: 'Retrieves a list of all availabilities',
  )
  @Get('/')
  Future<Response> getAll() async {
    return resultToResponse(await _service.getAll());
  }

  @ApiOperation(
    summary: 'Get availability by ID',
    description: 'Retrieves an availability by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The availability ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    return resultToResponse(await _service.getById(id));
  }

  @ApiOperation(
    summary: 'Create a new availability',
    description: 'Creates a new availability with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateAvailabilityDto dto) async {
    return resultToResponse(await _service.create(dto));
  }

  @ApiOperation(
    summary: 'Update an availability',
    description: 'Updates an existing availability with the provided data',
  )
  @ApiParam(name: 'id', description: 'The availability ID', required: true)
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateAvailabilityDto dto,
  ) async {
    return resultToResponse(await _service.update(id, dto));
  }

  @ApiOperation(
    summary: 'Delete an availability',
    description: 'Deletes an availability by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The availability ID', required: true)
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async {
    return resultToResponse(await _service.delete(id));
  }
}
