import 'package:innovacad_api/src/core/http_mapper.dart';
import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_user_update_dto.dart';
import 'package:innovacad_api/src/domain/services/trainee_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Trainees", description: "CRUD endpoint documentation for trainees")
@Controller("/trainees")
class TraineeController {
  final ITraineeService _service;

  TraineeController(this._service);

  @Get('/')
  Future<Response> getAll() async {
    final Result<List<dynamic>> result = await _service.getAll();
    return resultToResponse(result);
  }

  @Get('/<id>')
  Future<Response> getById(@Query("id") String id) async {
    final Result<dynamic> result = await _service.getById(id);
    return resultToResponse(result);
  }

  @Post("/")
  Future<Response> create(@Body() TraineeCreateDto dto) async {
    final Result<dynamic> result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Query('id') String id,
    @Body() TraineeUserUpdateDto dto,
  ) async {
    final Result<dynamic> result = await _service.update(id, dto);
    return resultToResponse(result);
  }

  @Delete("/<id>")
  Future<Response> delete(@Query('id') String id) async {
    final Result<dynamic> result = await _service.delete(id);
    return resultToResponse(result);
  }
}
