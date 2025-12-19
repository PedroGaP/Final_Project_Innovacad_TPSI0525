import 'package:innovacad_api/src/domain/dtos/trainer_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Service()
abstract interface class ITrainerService {
  Future<List<Trainer>?> getAll();
  Future<Trainer?> getById(Uuid id);
  Future<Trainer?> create(TrainerCreateDto dto);
  Future<Trainer?> update(TrainerUpdateDto dto);
  Future<Trainer?> delete(Uuid id);
}
