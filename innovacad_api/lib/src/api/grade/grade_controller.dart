import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/grade/dto/batch/batch_grade_dto.dart';
import 'package:innovacad_api/src/data/grade/dto/finalize/finalize_grade_dto.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Grades", description: "CRUD for grades")
@Controller("/grades")
class GradeController {
  final IGradeService _service;

  GradeController(this._service);

  @ApiOperation(summary: 'Batch create or update grades')
  @Post('/batch')
  Future<Response> batchUpsert(
    Request request,
    @Body() BatchGradeDto dto,
    @Context() ExtendedUserDetails user,
  ) async {
    return resultToResponse(await _service.batchUpsert(dto, user));
  }

  @ApiOperation(summary: 'Finalize grades (Coordinator only)')
  @Post('/finalize')
  Future<Response> finalizeGrades(
    Request request,
    @Body() FinalizeGradeDto dto,
    @Context() ExtendedUserDetails user,
  ) async {
    return resultToResponse(await _service.finalizeGrades(dto, user));
  }

  @ApiOperation(summary: 'Get grades for a module')
  @Get('/module/<classModuleId>')
  Future<Response> getByModule(
    Request request,
    @Param('classModuleId') String classModuleId,
    @Context() ExtendedUserDetails user,
  ) async {
    return resultToResponse(await _service.getByClassModule(classModuleId));
  }

  @ApiOperation(
    summary: 'Get all grades',
    description: 'Retrieves a list of all grades',
  )
  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @ApiOperation(
    summary: 'Get grade by ID',
    description: 'Retrieves a grade by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The grade ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @ApiOperation(
    summary: 'Create a new grade',
    description: 'Creates a new grade with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateGradeDto dto) async =>
      resultToResponse(await _service.create(dto));

  @ApiOperation(
    summary: 'Update a grade',
    description: 'Updates an existing grade with the provided data',
  )
  @ApiParam(name: 'id', description: 'The grade ID', required: true)
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateGradeDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @ApiParam(name: 'id', description: 'The grade ID', required: true)
  @ApiOperation(
    summary: 'Delete a grade',
    description: 'Deletes a grade by their unique identifier',
  )
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));

  @ApiParam(name: 'id', description: 'The trainee ID', required: true)
  @ApiOperation(
    summary: 'Fetch grades by Trainee Id',
    description: 'Fetchesgrades by their trainee unique identifier',
  )
  @Get('/trainee/<traineeId>')
  Future<Response> fetchGradesByTraineeId(
    @Param("traineeId") String traineeId,
  ) async => resultToResponse(await _service.fetchGradesByTraineeId(traineeId));
}
