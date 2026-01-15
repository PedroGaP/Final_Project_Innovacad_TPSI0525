import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/course/service/i_course_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Courses", description: "CRUD endpoint documentation for courses")
@Controller("/courses")
class CourseController {
  final ICourseService _service;

  CourseController(this._service);

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
  Future<Response> create(@Body() CreateCourseDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateCourseDto dto,
  ) async {
    if (dto.courseId != id) {
       // Consider strictly validating or just using ID from body if path ID is ignored or vice versa
    }
    final result = await _service.update(dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(
    @Param("id") String id,
    @Body() DeleteCourseDto dto // DTO requires courseId, so body is expected even for delete
  ) async {
      final result = await _service.delete(dto);
      return resultToResponse(result);
  }
}
