import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IModuleRepository {
  Future<Result<List<OutputModuleDao>>> getAll();
  Future<Result<OutputModuleDao>> getById(String id);
  Future<Result<OutputModuleDao>> create(CreateModuleDto dto);
  Future<Result<OutputModuleDao>> update(UpdateModuleDto dto);
  Future<Result<OutputModuleDao>> delete(DeleteModuleDto dto);
}
