import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/schedule/dto/auto/auto_schedule_dto.dart';
import 'package:innovacad_api/src/domain/schedule/service/i_schedule_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Schedules", description: "CRUD for schedules")
@Controller("/schedules")
class ScheduleController {
  final IScheduleService _service;

  ScheduleController(this._service);

  @ApiOperation(
    summary: 'Get all schedules',
    description: 'Retrieves a list of all schedules',
  )
  @Get('/')
  Future<Response> getAll() async {
    return resultToResponse(await _service.getAll());
  }

  @ApiOperation(
    summary: 'Get schedules by User ID',
    description:
        'Retrieves schedules associated with a specific user (Trainer)',
  )
  @ApiParam(
    name: 'userId',
    description: 'The User ID (from auth)',
    required: true,
  )
  @Get('/user/<userId>')
  Future<Response> getByUser(@Param("userId") String userId) async {
    return resultToResponse(await _service.getByUser(userId));
  }

  @ApiOperation(
    summary: 'Get schedule by ID',
    description: 'Retrieves a schedule by a class unique identifier',
  )
  @ApiParam(name: 'id', description: 'The class ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    return resultToResponse(await _service.getById(id));
  }

  @ApiOperation(
    summary: 'Create a new schedule',
    description: 'Creates a new schedule with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateScheduleDto dto) async {
    return resultToResponse(await _service.create(dto));
  }

  @ApiParam(name: 'id', description: 'The schedule ID', required: true)
  @ApiOperation(
    summary: 'Update a schedule',
    description: 'Updates an existing schedule with the provided data',
  )
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateScheduleDto dto,
  ) async {
    return resultToResponse(await _service.update(id, dto));
  }

  @ApiParam(name: 'id', description: 'The schedule ID', required: true)
  @ApiOperation(
    summary: 'Delete a schedule',
    description: 'Deletes a schedule by their unique identifier',
  )
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async {
    return resultToResponse(await _service.delete(id));
  }

  @ApiOperation(
    summary: 'Auto Generate Schedule',
    description: 'Tries to generate a schedule for a class',
  )
  @Post('/auto')
  Future<Response> generateAutomaticSchedule(
    @Body() AutoScheduleDto dto,
  ) async {
    return resultToResponse(await _service.generateAutomaticSchedule(dto));
  }
}
