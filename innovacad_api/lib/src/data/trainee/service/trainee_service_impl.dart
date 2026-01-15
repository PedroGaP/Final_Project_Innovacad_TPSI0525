import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/trainee/repository/i_trainee_repository.dart';
import 'package:innovacad_api/src/domain/trainee/service/i_trainee_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class TraineeServiceImpl implements ITraineeService {
  final ITraineeRepository _repository;

  TraineeServiceImpl(this._repository);

  @override
  Future<Result<List<OutputTraineeDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputTraineeDao>> getById(String id) async =>
      _repository.getById(id);

  @override
  Future<Result<OutputTraineeDao>> create(CreateTraineeDto dto) async =>
      _repository.create(dto);

  @override
  Future<Result<OutputTraineeDao>> update(
    String id,
    UpdateTraineeDto dto,
  ) async => _repository.update(id, dto);

  @override
  Future<Result<OutputTraineeDao>> delete(String id) async =>
      _repository.delete(id);
}
