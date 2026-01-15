import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/course_module/service/i_course_module_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Course Modules", description: "CRUD for Course-Module Associations")
@Controller("/courses-modules")
class CourseModuleController {
  final ICourseModuleService _service;

  CourseModuleController(this._service);

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
  Future<Response> create(@Body() CreateCourseModuleDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateCourseModuleDto dto,
  ) async {
    if (dto.coursesModulesId != id) {
       // Validate
    }
    final result = await _service.update(dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(
    @Param("id") String id,
    @Body() DeleteCourseModuleDto dto 
  ) async {
      final result = await _service.delete(dto);
      return resultToResponse(result);
  }
}
