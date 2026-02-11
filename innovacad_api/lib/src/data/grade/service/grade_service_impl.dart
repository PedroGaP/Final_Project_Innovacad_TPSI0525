import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/grade/dto/batch/batch_grade_dto.dart';
import 'package:innovacad_api/src/data/grade/dto/finalize/finalize_grade_dto.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Service()
class GradeServiceImpl implements IGradeService {
  final IGradeRepository _repository;

  GradeServiceImpl(this._repository);

  @override
  Future<Result<List<OutputGradeDao>>> getAll() async =>
      await _repository.getAll();

  @override
  Future<Result<OutputGradeDao>> getById(String id) async =>
      await _repository.getById(id);

  @override
  Future<Result<OutputGradeDao>> create(CreateGradeDto dto) async =>
      await _repository.create(dto);

  @override
  Future<Result<OutputGradeDao>> update(String id, UpdateGradeDto dto) async =>
      await _repository.update(id, dto);

  @override
  Future<Result<OutputGradeDao>> delete(String id) async =>
      await _repository.delete(id);

  @override
  Future<Result<bool>> batchUpsert(
    BatchGradeDto dto,
    ExtendedUserDetails user,
  ) async {
    try {
      return await _repository.batchUpsert(dto, user);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<bool>> finalizeGrades(
    FinalizeGradeDto dto,
    ExtendedUserDetails user,
  ) async {
    try {
      final canFinalize = await _repository.canFinalizeGrades(
        userId: user.id,
        userRole: user.roles.first,
        classModuleId: dto.classModuleId,
      );

      if (!canFinalize) {
        return Result.failure(
          AppError(
            AppErrorType.forbidden,
            "Only coordinators of this class or admins can finalize grades.",
          ),
        );
      }

      return await _repository.finalizeGrades(dto.classModuleId);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<List<OutputGradeDao>>> getByClassModule(
    String classModuleId,
  ) async {
    try {
      return await _repository.getByClassModule(classModuleId);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
