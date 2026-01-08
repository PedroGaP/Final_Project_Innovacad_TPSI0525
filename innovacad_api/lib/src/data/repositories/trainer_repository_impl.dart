import 'package:innovacad_api/src/domain/dtos/trainer/trainer_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainer/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:innovacad_api/src/domain/repositories/trainer_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class TrainerRepositoryImpl implements ITrainerRepository {
  /*
  TODO: Inject DB

  final ITrainerRepository _database;

  TrainerRepositoryImpl(this._database);
  */

  @override
  Future<List<Trainer>?> getAll() {
    // TODO: To Implement
    throw UnimplementedError();
  }

  @override
  Future<Trainer?> getById(String id) {
    // TODO: To Implement
    throw UnimplementedError();
  }

  @override
  Future<Trainer?> create(TrainerCreateDto dto) {
    // TODO: To Implement
    throw UnimplementedError();
  }

  @override
  Future<Trainer?> update(TrainerUpdateDto dto) {
    // TODO: To Implement
    throw UnimplementedError();
  }

  @override
  Future<Trainer?> delete(String id) {
    // TODO: To Implement
    throw UnimplementedError();
  }
}
