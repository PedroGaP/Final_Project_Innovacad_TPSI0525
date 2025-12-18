import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:innovacad_api/src/domain/repositories/trainer_repository.dart';

class TrainerRepositoryImpl implements ITrainerRepository {
  final ITrainerRepository _trainerRepository;

  TrainerRepositoryImpl(this._trainerRepository);

  @override
  Future<Trainer> create(Trainer trainer) {
    // TODO: implement createFormador
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement deleteFormador
    throw UnimplementedError();
  }

  @override
  Future<List<Trainer>> getAll() {
    // TODO: implement getAllFormadores
    throw UnimplementedError();
  }

  @override
  Future<Trainer> getById(int id) {
    // TODO: implement getFormadorById
    throw UnimplementedError();
  }

  @override
  Future<Trainer> update(Trainer trainer) {
    // TODO: implement updateFormador
    throw UnimplementedError();
  }
}
