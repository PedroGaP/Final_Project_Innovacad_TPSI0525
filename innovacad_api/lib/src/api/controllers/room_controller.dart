import 'package:innovacad_api/src/domain/dtos/room/room_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/room/room_update_dto.dart';
import 'package:innovacad_api/src/data/services/room_service_impl.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Rooms", description: "CRUD for rooms")
@Controller("/rooms")
class RoomController {
  final RoomServiceImpl _service;

  RoomController(this._service);

  @Get('/')
  Future<Response> getAll() async => Response.ok(await _service.getAll());

  @Get('/<id>')
  Future<Response> getById(@Param('id') String id) async =>
      Response.ok(await _service.getById(id));

  @Post('/')
  Future<Response> create(@Body() RoomCreateDto dto) async =>
      Response.ok(await _service.create(dto));

  @Put('/')
  Future<Response> update(@Body() RoomUpdateDto dto) async =>
      Response.ok(await _service.update(dto));

  @Delete('/<id>')
  Future<Response> delete(@Param() String id) async =>
      Response.ok(await _service.delete(id));
}
