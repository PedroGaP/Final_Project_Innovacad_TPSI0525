import 'package:innovacad_api/src/domain/daos/trainee/trainee_user_dao.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_user_update_dto.dart';

abstract interface class ITraineeService {
  Future<Result<List<TraineeUserDao>>> getAll();
  Future<Result<TraineeUserDao>> getById(String id);
  Future<Result<TraineeUserDao>> create(TraineeCreateDto dto);
  Future<Result<TraineeUserDao>> update(String id, TraineeUserUpdateDto dto);
  Future<Result<TraineeUserDao>> delete(String id);
}
