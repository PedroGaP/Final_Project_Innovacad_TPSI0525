import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IClassRepository {
  Future<Result<List<OutputClassDao>>> getAll();
  Future<Result<OutputClassDao>> getById(String id);
  Future<Result<OutputClassDao>> create(CreateClassDto dto);
  Future<Result<OutputClassDao>> update(String id, UpdateClassDto dto);
  Future<Result<OutputClassDao>> delete(String id);
}
