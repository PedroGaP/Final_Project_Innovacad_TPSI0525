import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Courses", description: "CRUD endpoint documentation for courses")
@Controller("/courses")
class CourseController {
  final ICourseService _service;

  CourseController(this._service);

  @ApiOperation(
    summary: 'Get all courses',
    description: 'Retrieves a list of all courses',
  )
  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @ApiOperation(
    summary: 'Get course by ID',
    description: 'Retrieves a course by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The course ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @ApiOperation(
    summary: 'Create a new course',
    description: 'Creates a new course with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateCourseDto dto) async =>
      resultToResponse(await _service.create(dto));

  @ApiParam(name: 'id', description: 'The course ID', required: true)
  @ApiOperation(
    summary: 'Update a course',
    description: 'Updates an existing course with the provided data',
  )
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateCourseDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @ApiParam(name: 'id', description: 'The course ID', required: true)
  @ApiOperation(
    summary: 'Delete a course',
    description: 'Deletes a course by their unique identifier',
  )
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
