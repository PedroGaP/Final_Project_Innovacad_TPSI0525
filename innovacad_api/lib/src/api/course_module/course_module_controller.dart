import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Course Modules", description: "CRUD for Course-Module Associations")
@Controller("/courses-modules")
class CourseModuleController {
  final ICourseModuleService _service;

  CourseModuleController(this._service);

  @ApiOperation(
    summary: 'Get all course-module associations',
    description: 'Retrieves a list of all course-module associations',
  )
  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @ApiOperation(
    summary: 'Get course-module association by ID',
    description:
        'Retrieves a course-module association by their unique identifier',
  )
  @ApiParam(
    name: 'id',
    description: 'The course-module association ID',
    required: true,
  )
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @ApiOperation(
    summary: 'Create a new course-module association',
    description:
        'Creates a new course-module association with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateCourseModuleDto dto) async =>
      resultToResponse(await _service.create(dto));

  @ApiOperation(
    summary: 'Update a course-module association',
    description:
        'Updates an existing course-module association with the provided data',
  )
  @ApiParam(
    name: 'id',
    description: 'The course-module association ID',
    required: true,
  )
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateCourseModuleDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @ApiOperation(
    summary: 'Delete a course-module association',
    description:
        'Deletes a course-module association by their unique identifier',
  )
  @ApiParam(
    name: 'id',
    description: 'The course-module association ID',
    required: true,
  )
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
