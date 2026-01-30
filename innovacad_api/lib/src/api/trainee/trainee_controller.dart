import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/trainee/service/i_trainee_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Trainees", description: "CRUD for trainees")
@Controller("/trainees")
class TraineeController {
  final ITraineeService _service;

  TraineeController(this._service);

  @ApiOperation(
    summary: 'Get all trainees',
    description: 'Retrieves a list of all trainees',
  )
  @Get('/')
  Future<Response> getAll() async {
    final result = await _service.getAll();
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Get trainee by ID',
    description: 'Retrieves a trainee by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The trainee ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    final result = await _service.getById(id);
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Create a new trainee',
    description: 'Creates a new trainee with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateTraineeDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Update a trainee',
    description: 'Updates an existing trainee with the provided data',
  )
  @ApiParam(name: 'id', description: 'The trainee ID', required: true)
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateTraineeDto dto,
  ) async {
    final result = await _service.update(id, dto);
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Delete a trainee',
    description: 'Deletes a trainee by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The trainee ID', required: true)
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async {
    final result = await _service.delete(id);
    return resultToResponse(result);
  }
}
