import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IClassModuleRepository {
  Future<Result<List<OutputClassModuleDao>>> getAll();
  Future<Result<OutputClassModuleDao>> getById(String id);
  Future<Result<OutputClassModuleDao>> create(CreateClassModuleDto dto);
  Future<Result<OutputClassModuleDao>> update(
    String id,
    UpdateClassModuleDto dto,
  );
  Future<Result<OutputClassModuleDao>> delete(String id);
}
