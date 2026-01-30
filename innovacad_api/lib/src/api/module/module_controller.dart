import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Modules", description: "CRUD endpoint documentation for modules")
@Controller("/modules")
class ModuleController {
  final IModuleService _service;

  ModuleController(this._service);

  @ApiOperation(
    summary: 'Get all modules',
    description: 'Retrieves a list of all modules',
  )
  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @ApiOperation(
    summary: 'Get module by ID',
    description: 'Retrieves a module by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The module ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @ApiOperation(
    summary: 'Create a new module',
    description: 'Creates a new module with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateModuleDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @ApiParam(name: 'id', description: 'The module ID', required: true)
  @ApiOperation(
    summary: 'Update a module',
    description: 'Updates an existing module with the provided data',
  )
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateModuleDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @ApiParam(name: 'id', description: 'The module ID', required: true)
  @ApiOperation(
    summary: 'Delete a module',
    description: 'Deletes a module by their unique identifier',
  )
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
