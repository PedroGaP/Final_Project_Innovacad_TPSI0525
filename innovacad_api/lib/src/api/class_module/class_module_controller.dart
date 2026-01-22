import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/class_module/service/i_class_module_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "ClassModules", description: "CRUD for class modules")
@Controller("/classes-modules")
class ClassModuleController {
  final IClassModuleService _service;

  ClassModuleController(this._service);

  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @Post("/")
  Future<Response> create(@Body() CreateClassModuleDto dto) async =>
      resultToResponse(await _service.create(dto));

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateClassModuleDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
