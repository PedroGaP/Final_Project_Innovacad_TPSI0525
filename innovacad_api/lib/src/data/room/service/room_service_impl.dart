import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Service()
class RoomServiceImpl implements IRoomService {
  final IRoomRepository _repository;

  RoomServiceImpl(this._repository);

  @override
  Future<Result<List<OutputRoomDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<OutputRoomDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputRoomDao>> create(CreateRoomDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputRoomDao>> update(String id, UpdateRoomDto dto) async =>
      await _repository.update(id, dto);

  @override
  Future<Result<OutputRoomDao>> delete(String id) async =>
      await _repository.delete(id);
}
