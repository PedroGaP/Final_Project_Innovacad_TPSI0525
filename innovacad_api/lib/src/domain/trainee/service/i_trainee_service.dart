import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/trainee/dao/output/output_trainee_dao.dart';
import 'package:innovacad_api/src/data/trainee/dto/create/create_trainee_dto.dart';
import 'package:innovacad_api/src/data/trainee/dto/update/update_trainee_dto.dart';

abstract class ITraineeService {
  Future<Result<List<OutputTraineeDao>>> getAll();
  Future<Result<OutputTraineeDao>> getById(String id);
  Future<Result<OutputTraineeDao>> create(CreateTraineeDto dto);
  Future<Result<OutputTraineeDao>> update(String id, UpdateTraineeDto dto);
  Future<Result<OutputTraineeDao>> delete(String id);
}
