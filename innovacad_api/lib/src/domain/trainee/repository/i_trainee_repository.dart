import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';

abstract class ITraineeRepository
    extends
        IUserRepository<OutputTraineeDao, CreateTraineeDto, UpdateTraineeDto> {
  Future<Result<List<OutputTraineeDao>>> getAll();
  Future<Result<OutputTraineeDao>> getById(String id);
  Future<Result<OutputTraineeDao>> create(CreateTraineeDto dto);
  Future<Result<OutputTraineeDao>> update(String id, UpdateTraineeDto dto);
  Future<Result<OutputTraineeDao>> delete(String id);
}
