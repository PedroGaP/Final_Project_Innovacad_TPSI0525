import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/class_module/service/i_class_module_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "ClassModules", description: "CRUD for class modules")
@Controller("/classes-modules")
class ClassModuleController {
  final IClassModuleService _service;

  ClassModuleController(this._service);

  @ApiOperation(
    summary: 'Get all class modules',
    description: 'Retrieves a list of all class modules',
  )
  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @ApiOperation(
    summary: 'Get class module by ID',
    description: 'Retrieves a class module by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The class module ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @ApiOperation(
    summary: 'Create a new class module',
    description: 'Creates a new class module with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateClassModuleDto dto) async =>
      resultToResponse(await _service.create(dto));

  @ApiOperation(
    summary: 'Update a class module',
    description: 'Updates an existing class module with the provided data',
  )
  @ApiParam(name: 'id', description: 'The class module ID', required: true)
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateClassModuleDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @ApiOperation(
    summary: 'Delete a class module',
    description: 'Deletes a class module by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The class module ID', required: true)
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
