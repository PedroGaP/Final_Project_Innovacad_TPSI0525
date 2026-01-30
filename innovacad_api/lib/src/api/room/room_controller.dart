import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/room/service/i_room_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Rooms", description: "CRUD endpoint documentation for rooms")
@Controller("/rooms")
class RoomController {
  final IRoomService _service;

  RoomController(this._service);

  @ApiOperation(
    summary: 'Get all rooms',
    description: 'Retrieves a list of all rooms',
  )
  @Get('/')
  Future<Response> getAll() async => resultToResponse(await _service.getAll());

  @ApiOperation(
    summary: 'Get room by ID',
    description: 'Retrieves a room by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The room ID', required: true)
  @Get('/<id>')
  Future<Response> getById(@Param("id") String id) async =>
      resultToResponse(await _service.getById(id));

  @ApiOperation(
    summary: 'Create a new room',
    description: 'Creates a new room with the provided data',
  )
  @Post("/")
  Future<Response> create(@Body() CreateRoomDto dto) async =>
      resultToResponse(await _service.create(dto));

  @ApiOperation(
    summary: 'Update a room',
    description: 'Updates an existing room with the provided data',
  )
  @ApiParam(name: 'id', description: 'The room ID', required: true)
  @Put("/<id>")
  Future<Response> update(
    @Param("id") String id,
    @Body() UpdateRoomDto dto,
  ) async => resultToResponse(await _service.update(id, dto));

  @ApiOperation(
    summary: 'Delete a room',
    description: 'Deletes a room by their unique identifier',
  )
  @ApiParam(name: 'id', description: 'The room ID', required: true)
  @Delete('/<id>')
  Future<Response> delete(@Param("id") String id) async =>
      resultToResponse(await _service.delete(id));
}
