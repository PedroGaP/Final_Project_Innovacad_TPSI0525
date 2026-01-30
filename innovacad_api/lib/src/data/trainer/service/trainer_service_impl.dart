import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Service()
class TrainerServiceImpl implements ITrainerService {
  final ITrainerRepository _repository;

  TrainerServiceImpl(this._repository);

  @override
  Future<Result<List<OutputTrainerDao>>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Result<OutputTrainerDao>> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Result<OutputTrainerDao>> create(CreateTrainerDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Result<OutputTrainerDao>> update(
    String id,
    UpdateTrainerDto dto,
  ) async {
    return await _repository.update(id, dto);
  }

  @override
  Future<Result<OutputTrainerDao>> delete(String id) async {
    return await _repository.delete(id);
  }

  @override
  Future<Result<OutputTrainerDao>> linkAccount(UserLinkAccountDto dto) {
    throw UnimplementedError();
  }
}
