import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Classes", description: "CRUD endpoint documentation for classes")
@Controller("/classes")
class ClassController {
  final IClassService _service;

  ClassController(this._service);

  @ApiOperation(
    summary: 'Get all classes',
    description: 'Retrieves a list of all classes',
  )
  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @ApiOperation(
    summary: 'Get class by ID',
    description: 'Retrieves a class by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The class ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @ApiOperation(
    summary: 'Create a new class',
    description: 'Creates a new class with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateClassDto dto) async =>
      resultToResponse(await _service.create(dto));

  @ApiOperation(
    summary: 'Update a class',
    description: 'Updates an existing class with the provided data',
  )
  @ApiParam(name: 'id', description: 'The class ID', required: true)
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateClassDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @ApiOperation(
    summary: 'Delete a class',
    description: 'Deletes a class by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The class ID', required: true)
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
