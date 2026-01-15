import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/grade/service/i_grade_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Grades", description: "CRUD for grades")
@Controller("/grades")
class GradeController {
  final IGradeService _service;

  GradeController(this._service);

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
  Future<Response> create(@Body() CreateGradeDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateGradeDto dto,
  ) async {
    if (dto.gradeId != id) {
       // Validate
    }
    final result = await _service.update(dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(
    @Param("id") String id,
    @Body() DeleteGradeDto dto 
  ) async {
      final result = await _service.delete(dto);
      return resultToResponse(result);
  }
}
