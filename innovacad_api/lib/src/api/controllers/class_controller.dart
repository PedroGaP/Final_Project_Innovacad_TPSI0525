import 'dart:convert';

import 'package:innovacad_api/src/api/middlewares/logger_middleware.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_update_dto.dart';
import 'package:innovacad_api/src/domain/services/class_service.dart';
import 'package:vaden/vaden.dart';

@UseMiddleware([LoggerMiddleware])
@Api(tag: "Classes", description: "CRUD for classes")
@Controller("/classes")
class ClassController {
  final IClassService _service;

  ClassController(this._service);

  @Get('/')
  Future<Response> getAll() async {
    final req = await _service.getAll();
    List? response = req?.map((k) => k.toJson()).toList();

    print(response);

    return Response.ok(
      jsonEncode(response),
      headers: {'content-type': 'application/json'},
    );
  }

  @Get('/<id>')
  Future<Response> getById(@Query('id') String id) async =>
      Response.ok(jsonEncode(await _service.getById(id)));

  @Post('/')
  Future<Response> create(@Body() ClassModelCreateDto dto) async =>
      Response.ok(jsonEncode(await _service.create(dto)));

  @Put('/')
  Future<Response> update(
    @Query('id') String id,
    @Body() ClassModelUpdateDto dto,
  ) async => Response.ok(jsonEncode(await _service.update(id, dto)));

  @Delete('/<id>')
  Future<Response> delete(@Query('id') String id) async =>
      Response.ok(jsonEncode(await _service.delete(id)));
}
