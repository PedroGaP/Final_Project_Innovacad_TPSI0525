import 'package:innovacad_api/src/core/http_mapper.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/trainer/service/i_trainer_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Trainers", description: "CRUD endpoint documentation for trainers")
@Controller("/trainers")
class TrainerController {
  final ITrainerService _service;

  TrainerController(this._service);

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
  Future<Response> create(@Body() CreateTrainerDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateTrainerDto dto,
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
