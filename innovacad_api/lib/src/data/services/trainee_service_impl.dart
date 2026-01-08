import 'package:innovacad_api/src/data/repositories/trainee_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainee.dart';
import 'package:innovacad_api/src/domain/services/trainee_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class TraineeServiceImpl implements ITraineeService {
  final TraineeRepositoryImpl _repository;

  TraineeServiceImpl(this._repository);

  @override
  Future<List<Trainee>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Trainee?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Trainee?> create(TraineeCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Trainee?> update(TraineeUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Trainee?> delete(String id) async {
    return await _repository.delete(id);
  }
}
