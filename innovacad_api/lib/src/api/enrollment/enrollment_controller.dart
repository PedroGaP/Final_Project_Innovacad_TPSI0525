import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Enrollments", description: "CRUD for enrollments")
@Controller("/enrollments")
class EnrollmentController {
  final IEnrollmentService _service;

  EnrollmentController(this._service);

  @ApiOperation(
    summary: 'Get all enrollments',
    description: 'Retrieves a list of all enrollments',
  )
  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @ApiOperation(
    summary: 'Get enrollment by ID',
    description: 'Retrieves an enrollment by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The enrollment ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @ApiOperation(
    summary: 'Create a new enrollment',
    description: 'Creates a new enrollment with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateEnrollmentDto dto) async =>
      resultToResponse(await _service.create(dto));

  @ApiParam(name: 'id', description: 'The enrollment ID', required: true)
  @ApiOperation(
    summary: 'Update an enrollment',
    description: 'Updates an existing enrollment with the provided data',
  )
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateEnrollmentDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @ApiOperation(
    summary: 'Delete an enrollment',
    description: 'Deletes an enrollment by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The enrollment ID', required: true)
  @Delete("/<id>")
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
