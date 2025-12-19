import 'package:innovacad_api/src/data/repositories/trainer_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/trainer_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:innovacad_api/src/domain/services/trainer_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class TrainerServiceImpl implements ITrainerService {
  final TrainerRepositoryImpl _repository;

  TrainerServiceImpl(this._repository);

  @override
  Future<List<Trainer>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Trainer?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Trainer?> create(TrainerCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Trainer?> update(TrainerUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Trainer?> delete(String id) async {
    return await _repository.delete(id);
  }
}
