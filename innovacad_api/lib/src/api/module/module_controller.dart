import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/module/service/i_module_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Modules", description: "CRUD endpoint documentation for modules")
@Controller("/modules")
class ModuleController {
  final IModuleService _service;

  ModuleController(this._service);

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
  Future<Response> create(@Body() CreateModuleDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateModuleDto dto,
  ) async {
    if (dto.moduleId != id) {
       // Validate consistency
    }
    final result = await _service.update(dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(
    @Param("id") String id,
    @Body() DeleteModuleDto dto 
  ) async {
      final result = await _service.delete(dto);
      return resultToResponse(result);
  }
}
