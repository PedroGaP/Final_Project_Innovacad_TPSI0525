import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/trainer/dao/output/output_public_trainer_dao.dart';
import 'package:innovacad_api/src/data/trainer/dao/skills_output/skill_output_dao.dart';
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

  Future<Result<List<OutputPublicTrainerDao>>> getAllPublic();
  Future<Result<List<int>>> generateTrainerPdf(String id);
  Future<Result<List<SkillOutputDao>>> getSkills(String id);
  Future<Result<List<String>>> getCoordinatedClasses(String id);
}
