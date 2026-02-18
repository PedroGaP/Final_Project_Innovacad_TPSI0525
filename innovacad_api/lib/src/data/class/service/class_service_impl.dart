import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/class/dao/output/output_public_class_dao.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Service()
class ClassServiceImpl implements IClassService {
  final IClassRepository _repository;

  ClassServiceImpl(this._repository);

  @override
  Future<Result<List<OutputClassDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<List<OutputPublicClassDao>>> getAllPublic() async {
    final classes = await _repository.getAll();

    if (classes.isFailure) return Result.failure(classes.error!);

    return Result.success(
      classes.data!
          .map((e) => OutputPublicClassDao.fromJson(e.toJson()))
          .toList(),
    );
  }

  @override
  Future<Result<OutputClassDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputClassDao>> create(CreateClassDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputClassDao>> update(String id, UpdateClassDto dto) async =>
      await _repository.update(id, dto);

  @override
  Future<Result<OutputClassDao>> delete(String id) async =>
      await _repository.delete(id);
}
