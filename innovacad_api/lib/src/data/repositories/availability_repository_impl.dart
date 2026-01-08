import 'package:innovacad_api/src/domain/dtos/availability/availability_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/availability/availability_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/availability.dart';
import 'package:innovacad_api/src/domain/repositories/availability_repository.dart';
import 'package:vaden/vaden.dart';

@Repository()
class AvailabilityRepositoryImpl implements IAvailabilityRepository {
  @override
  Future<List<Availability>?> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<Availability?> getById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Availability?> create(AvailabilityCreateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Availability?> update(AvailabilityUpdateDto dto) {
    throw UnimplementedError();
  }

  @override
  Future<Availability?> delete(String id) {
    throw UnimplementedError();
  }
}
