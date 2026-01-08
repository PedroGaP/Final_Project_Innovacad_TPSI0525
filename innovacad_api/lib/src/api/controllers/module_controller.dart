import 'package:innovacad_api/src/domain/dtos/module/module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/module/module_update_dto.dart';
import 'package:innovacad_api/src/data/services/module_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Modules", description: "CRUD for modules")
@Controller("/modules")
class ModuleController {
  final ModuleServiceImpl _service;

  ModuleController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() ModuleCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() ModuleUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
