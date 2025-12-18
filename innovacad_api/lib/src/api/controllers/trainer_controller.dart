import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:innovacad_api/src/domain/repositories/trainer_repository.dart';
import 'package:vaden/vaden.dart';

@Controller("/trainers")
class TrainerController {
  final ITrainerRepository _trainerRepository;

  TrainerController(this._trainerRepository);

  @Get('/')
  Future<List<Trainer>> getAllTrainers() async {
    return await _trainerRepository.getAll();
  }
}
