import 'package:innovacad_api/src/domain/dtos/trainer_create_dto.dart';
import 'package:innovacad_api/src/data/services/trainer_service_impl.dart';
import 'package:innovacad_api/src/domain/dtos/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Controller("/trainers")
class TrainerController {
  final TrainerServiceImpl _service;

  TrainerController(this._service);

  @Get('/')
  Future<List<Trainer>?> getAll() async {
    return await _service.getAll();
  }

  @Get('/<id>')
  Future<Trainer?> getById(@Param("id") Uuid id) async {
    return await _service.getById(id);
  }

  @Post("/")
  Future<Trainer?> create(@Body() TrainerCreateDto dto) async {
    return await _service.create(dto);
  }

  @Put("/")
  Future<Trainer?> update(@Body() TrainerUpdateDto dto) async {
    return await _service.update(dto);
  }

  @Delete("/<id>")
  Future<Trainer?> delete(@Param() Uuid id) async {
    return await _service.delete(id);
  }
}
