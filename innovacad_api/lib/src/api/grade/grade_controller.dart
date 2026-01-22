import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Grades", description: "CRUD for grades")
@Controller("/grades")
class GradeController {
  final IGradeService _service;

  GradeController(this._service);

  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @Post("/")
  Future<Response> create(@Body() CreateGradeDto dto) async =>
      resultToResponse(await _service.create(dto));

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateGradeDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
