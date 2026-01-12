import 'package:innovacad_api/src/domain/dtos/enrollment/enrollment_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/enrollment/enrollment_update_dto.dart';
import 'package:innovacad_api/src/data/services/enrollment_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Enrollments", description: "CRUD for enrollments")
@Controller("/enrollments")
class EnrollmentController {
  final EnrollmentServiceImpl _service;

  EnrollmentController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() EnrollmentCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() EnrollmentUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
