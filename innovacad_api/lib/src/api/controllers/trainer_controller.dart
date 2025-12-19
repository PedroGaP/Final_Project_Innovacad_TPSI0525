import 'package:innovacad_api/src/domain/dtos/trainer_create_dto.dart';
import 'package:innovacad_api/src/data/services/trainer_service_impl.dart';
import 'package:innovacad_api/src/domain/dtos/trainer_update_dto.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Trainers", description: "CRUD endpoint documentation for trainers")
@Controller("/trainers")
class TrainerController {
  final TrainerServiceImpl _service;

  TrainerController(this._service);

  @Get('/')
  Future<Response> getAll() async {
    return Response.ok(await _service.getAll());
  }

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    return Response.ok(await _service.getById(id));
  }

  @Post("/")
  Future<Response> create(@Body() TrainerCreateDto dto) async {
    return Response.ok(await _service.create(dto));
  }

  @Put("/")
  Future<Response> update(@Body() TrainerUpdateDto dto) async {
    return Response.ok(await _service.update(dto));
  }

  @Delete("/<id>")
  Future<Response> delete(@Param() String id) async {
    return Response.ok(await _service.delete(id));
  }
}
