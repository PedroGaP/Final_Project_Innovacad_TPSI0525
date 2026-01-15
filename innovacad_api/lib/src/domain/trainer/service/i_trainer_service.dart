import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';

abstract class ITrainerService
    extends IUserService<OutputTrainerDao, CreateTrainerDto, UpdateTrainerDto> {
  @override
  Future<Result<OutputTrainerDao>> create(CreateTrainerDto dto);

  @override
  Future<Result<OutputTrainerDao>> update(String id, UpdateTrainerDto dto);

  @override
  Future<Result<OutputTrainerDao>> delete(String id);

  @override
  Future<Result<List<OutputTrainerDao>>> getAll();

  @override
  Future<Result<OutputTrainerDao>> getById(String id);
}
