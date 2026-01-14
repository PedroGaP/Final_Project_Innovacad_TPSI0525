import 'package:innovacad_api/src/domain/daos/trainer/trainer_user_dao.dart';
import 'package:innovacad_api/src/domain/dtos/trainer/trainer_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainer/trainer_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:innovacad_api/src/core/result.dart';

abstract interface class ITrainerService {
  Future<Result<List<Trainer>>> getAll();
  Future<Result<Trainer>> getById(String id);
  Future<Result<TrainerUserDao>> create(TrainerCreateDto dto);
  Future<Result<Trainer>> update(String id, TrainerUpdateDto dto);
  Future<Result<Trainer>> delete(String id);
}
