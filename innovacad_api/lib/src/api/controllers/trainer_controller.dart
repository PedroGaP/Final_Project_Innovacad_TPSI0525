import 'package:innovacad_api/src/domain/dtos/trainer/trainer_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainer/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/services/trainer_service.dart';
import 'package:innovacad_api/src/core/http_mapper.dart';
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
  Future<Response> create(@Body() TrainerCreateDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Query('id') String id,
    @Body() TrainerUpdateDto dto,
  ) async {
    final result = await _service.update(id, dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async {
    final result = await _service.delete(id);
    return resultToResponse(result);
  }
}
