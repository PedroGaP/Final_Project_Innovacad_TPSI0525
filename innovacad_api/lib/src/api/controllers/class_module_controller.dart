import 'package:innovacad_api/src/domain/dtos/class_module/class_module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_module/class_module_update_dto.dart';
import 'package:innovacad_api/src/data/services/class_module_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "ClassModules", description: "CRUD for class modules")
@Controller("/classes-modules")
class ClassModuleController {
  final ClassModuleServiceImpl _service;

  ClassModuleController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() ClassModuleCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() ClassModuleUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
