import 'package:innovacad_api/src/domain/dtos/course/course_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/course/course_update_dto.dart';
import 'package:innovacad_api/src/domain/services/course_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Courses", description: "CRUD for courses")
@Controller("/courses")
class CourseController {
  final ICourseService _service;

  CourseController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() CourseCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() CourseUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
