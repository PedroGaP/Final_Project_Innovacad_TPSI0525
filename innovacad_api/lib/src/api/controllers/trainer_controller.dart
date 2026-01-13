import 'package:innovacad_api/src/domain/dtos/trainer/trainer_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainer/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/services/trainer_service.dart';
import 'package:innovacad_api/src/core/http_mapper.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Trainers", description: "CRUD endpoint documentation for trainers")
@Controller("/trainers")
class TrainerController {
  final ITrainerService _service;
  final DSON _dson;

  TrainerController(this._service, this._dson);

  @Get('/')
  Future<Response> getAll() async {
    final res = await _service.getAll();
    return resultToResponse<List>(res);
  }

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    final res = await _service.getById(id);
    return resultToResponse<Trainer>(res);
  }

  @Post("/")
  Future<Response> create(@Body() TrainerCreateDto dto) async {
    final res = await _service.create(dto);
    return resultToResponse<Trainer>(res);
  }

  @Put("/")
  Future<Response> update(
    @Query('id') String id,
    @Body() TrainerUpdateDto dto,
  ) async {
    final res = await _service.update(id, dto);
    return resultToResponse<Trainer>(res);
  }

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async {
    final res = await _service.delete(id);
    return resultToResponse<Trainer>(res);
  }
}
