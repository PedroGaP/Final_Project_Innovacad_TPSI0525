import 'package:innovacad_api/src/domain/daos/trainee_user_dao.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_user_update_dto.dart';
import 'package:innovacad_api/src/domain/repositories/trainee_repository.dart';
import 'package:innovacad_api/src/domain/services/trainee_service.dart';
import 'package:innovacad_api/src/core/result.dart';
import 'package:vaden/vaden.dart';

@Service()
class TraineeServiceImpl implements ITraineeService {
  final ITraineeRepository _repository;

  TraineeServiceImpl(this._repository);

  @override
  Future<Result<List<TraineeUserDao>>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Result<TraineeUserDao>> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Result<TraineeUserDao>> create(TraineeCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Result<TraineeUserDao>> update(
    String id,
    TraineeUserUpdateDto dto,
  ) async {
    return await _repository.update(id, dto);
  }

  @override
  Future<Result<TraineeUserDao>> delete(String id) async {
    return await _repository.delete(id);
  }
}
