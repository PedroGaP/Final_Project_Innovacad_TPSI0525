import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/data/services/trainee_service_impl.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_update_dto.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Trainees", description: "CRUD endpoint documentation for trainees")
@Controller("/trainees")
class TraineeController {
  final TraineeServiceImpl _service;

  TraineeController(this._service);

  @Get('/')
  Future<Response> getAll() async {
    return Response.ok(await _service.getAll());
  }

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    return Response.ok(await _service.getById(id));
  }

  @Post("/")
  Future<Response> create(@Body() TraineeCreateDto dto) async {
    return Response.ok(await _service.create(dto));
  }

  @Put("/")
  Future<Response> update(@Body() TraineeUpdateDto dto) async {
    return Response.ok(await _service.update(dto));
  }

  @Delete("/<id>")
  Future<Response> delete(@Param() String id) async {
    return Response.ok(await _service.delete(id));
  }
}
