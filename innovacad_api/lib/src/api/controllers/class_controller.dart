import 'package:innovacad_api/src/domain/dtos/class_model/class_model_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_update_dto.dart';
import 'package:innovacad_api/src/data/services/class_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Classes", description: "CRUD for classes")
@Controller("/classes")
class ClassController {
  final ClassServiceImpl _service;

  ClassController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() ClassModelCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() ClassModelUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
