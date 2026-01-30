import 'package:innovacad_api/src/core/http_mapper.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/trainer/service/i_trainer_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Trainers", description: "CRUD endpoint documentation for trainers")
@Controller("/trainers")
class TrainerController {
  final ITrainerService _service;

  TrainerController(this._service);

  @ApiOperation(
    summary: 'Get all trainers',
    description: 'Retrieves a list of all trainers',
  )
  @Get('/')
  Future<Response> getAll() async {
    final result = await _service.getAll();
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Get trainer by ID',
    description: 'Retrieves a trainer by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The trainer ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    final result = await _service.getById(id);
    return resultToResponse(result);
  }

  @ApiOperation(
    summary: 'Create a new trainer',
    description: 'Creates a new trainer with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateTrainerDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @ApiParam(name: 'id', description: 'The trainer ID', required: true)
  @ApiOperation(
    summary: 'Update a trainer',
    description: 'Updates an existing trainer with the provided data',
  )
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateTrainerDto dto,
  ) async {
    final result = await _service.update(id, dto);
    return resultToResponse(result);
  }

  @ApiParam(name: 'id', description: 'The trainer ID', required: true)
  @ApiOperation(
    summary: 'Delete a trainer',
    description: 'Deletes a trainer by their unique identifier',
  )
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async {
    final result = await _service.delete(id);
    return resultToResponse(result);
  }
}
