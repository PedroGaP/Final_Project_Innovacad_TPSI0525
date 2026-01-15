import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/trainee/service/i_trainee_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Trainees", description: "CRUD for trainees")
@Controller("/trainees")
class TraineeController {
  final ITraineeService _service;

  TraineeController(this._service);

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
  Future<Response> create(@Body() CreateTraineeDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateTraineeDto dto,
  ) async {
    final result = await _service.update(id, dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async {
    final result = await _service.delete(id);
    return resultToResponse(result);
  }
}
