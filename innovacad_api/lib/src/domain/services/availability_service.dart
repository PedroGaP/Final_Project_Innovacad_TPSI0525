import 'package:innovacad_api/src/domain/dtos/availability/availability_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/availability/availability_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/availability.dart';

abstract interface class IAvailabilityService {
  Future<List<Availability>?> getAll();
  Future<Availability?> getById(String id);
  Future<Availability?> create(AvailabilityCreateDto dto);
  Future<Availability?> update(AvailabilityUpdateDto dto);
  Future<Availability?> delete(String id);
}
