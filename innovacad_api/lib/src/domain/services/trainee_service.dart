import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/trainee.dart';

abstract interface class ITraineeService {
  Future<List<Trainee>?> getAll();
  Future<Trainee?> getById(String id);
  Future<Trainee?> create(TraineeCreateDto dto);
  Future<Trainee?> update(TraineeUpdateDto dto);
  Future<Trainee?> delete(String id);
}
