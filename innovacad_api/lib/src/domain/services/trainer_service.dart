import 'package:innovacad_api/src/domain/dtos/trainer_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';

abstract interface class ITrainerService {
  Future<List<Trainer>?> getAll();
  Future<Trainer?> getById(String id);
  Future<Trainer?> create(TrainerCreateDto dto);
  Future<Trainer?> update(TrainerUpdateDto dto);
  Future<Trainer?> delete(String id);
}
