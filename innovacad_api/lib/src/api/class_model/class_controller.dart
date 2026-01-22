import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Classes", description: "CRUD endpoint documentation for classes")
@Controller("/classes")
class ClassController {
  final IClassService _service;

  ClassController(this._service);

  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @Post("/")
  Future<Response> create(@Body() CreateClassDto dto) async =>
      resultToResponse(await _service.create(dto));

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateClassDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
