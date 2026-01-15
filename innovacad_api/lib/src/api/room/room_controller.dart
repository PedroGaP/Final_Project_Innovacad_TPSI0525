import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/room/service/i_room_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Rooms", description: "CRUD endpoint documentation for rooms")
@Controller("/rooms")
class RoomController {
  final IRoomService _service;

  RoomController(this._service);

  @Get('/')
  Future<Response> getAll() async {
    final result = await _service.getAll();
    return resultToResponse(result);
  }

  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async {
    final intId = int.tryParse(id);
    if (intId == null) {
        return Response.badRequest(body: "Invalid ID format");
    }
    final result = await _service.getById(intId);
    return resultToResponse(result);
  }

  @Post("/")
  Future<Response> create(@Body() CreateRoomDto dto) async {
    final result = await _service.create(dto);
    return resultToResponse(result);
  }

  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateRoomDto dto,
  ) async {
    final intId = int.tryParse(id);
    if (intId == null) {
        return Response.badRequest(body: "Invalid ID format");
    }
    if (dto.roomId != intId) {
       // Validate
    }
    final result = await _service.update(dto);
    return resultToResponse(result);
  }

  @Delete('/<id>')
  Future<Response> delete(
    @Param("id") String id,
    @Body() DeleteRoomDto dto 
  ) async {
      // DTO has roomId as int.
      final result = await _service.delete(dto);
      return resultToResponse(result);
  }
}
