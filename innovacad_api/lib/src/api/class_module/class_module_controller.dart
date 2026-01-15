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
  Future<Response> create(@Body() CreateClassModuleDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateClassModuleDto dto,
  ) async {
    if (dto.classesModulesId != id) {
       // Validate
    }
    final result = await _service.update(dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(
    @Param("id") String id,
    @Body() DeleteClassModuleDto dto 
  ) async {
      final result = await _service.delete(dto);
      return resultToResponse(result);
  }
}
