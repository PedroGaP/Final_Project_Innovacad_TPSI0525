import 'package:innovacad_api/src/domain/dtos/grade/grade_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/grade/grade_update_dto.dart';
import 'package:innovacad_api/src/data/services/grade_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Grades", description: "CRUD for grades")
@Controller("/grades")
class GradeController {
  final GradeServiceImpl _service;

  GradeController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() GradeCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() GradeUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
