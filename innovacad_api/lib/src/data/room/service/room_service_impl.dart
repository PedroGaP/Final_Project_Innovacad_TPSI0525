import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/room/repository/i_room_repository.dart';
import 'package:innovacad_api/src/domain/room/service/i_room_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class RoomServiceImpl implements IRoomService {
  final IRoomRepository _repository;

  RoomServiceImpl(this._repository);

  @override
  Future<Result<List<OutputRoomDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputRoomDao>> getById(int id) async => _repository.getById(id);

  @override
  Future<Result<OutputRoomDao>> create(CreateRoomDto dto) async => _repository.create(dto);

  @override
  Future<Result<OutputRoomDao>> update(UpdateRoomDto dto) async => _repository.update(dto);

  @override
  Future<Result<OutputRoomDao>> delete(DeleteRoomDto dto) async => _repository.delete(dto);
}
