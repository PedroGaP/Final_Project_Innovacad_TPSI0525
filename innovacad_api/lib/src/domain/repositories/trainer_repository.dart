import 'package:innovacad_api/src/domain/entities/trainer.dart';
import 'package:vaden/vaden.dart';

@Repository()
abstract class ITrainerRepository {
  Future<List<Trainer>> getAll();
  Future<Trainer> getById(int id);
  Future<Trainer> create(Trainer trainer);
  Future<Trainer> update(Trainer trainer);
  Future<void> delete(int id);
}
