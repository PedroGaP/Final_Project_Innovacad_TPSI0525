import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainee.dart';
import 'package:innovacad_api/src/domain/repositories/trainee_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class TraineeRepositoryImpl implements ITraineeRepository {
  /*
  TODO: Inject DB

  final ITrainerRepository _database;

  TrainerRepositoryImpl(this._database);
  */

  @override
  Future<List<Trainee>?> getAll() {
    // TODO: To Implement
    throw UnimplementedError();
  }

  @override
  Future<Trainee?> getById(String id) {
    // TODO: To Implement
    throw UnimplementedError();
  }

  @override
  Future<Trainee?> create(TraineeCreateDto dto) {
    // TODO: To Implement
    throw UnimplementedError();
  }

  @override
  Future<Trainee?> update(TraineeUpdateDto dto) {
    // TODO: To Implement
    throw UnimplementedError();
  }

  @override
  Future<Trainee?> delete(String id) {
    // TODO: To Implement
    throw UnimplementedError();
  }
}
