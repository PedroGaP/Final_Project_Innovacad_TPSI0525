import 'package:innovacad_api/src/domain/dtos/course_module/course_module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/course_module/course_module_update_dto.dart';
import 'package:innovacad_api/src/data/services/course_module_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "CourseModules", description: "CRUD for course modules")
@Controller("/courses-modules")
class CourseModuleController {
  final CourseModuleServiceImpl _service;

  CourseModuleController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() CourseModuleCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() CourseModuleUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
