import 'package:innovacad_api/src/data/repositories/availability_repository_impl.dart';
import 'package:innovacad_api/src/domain/dtos/availability/availability_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/availability/availability_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/availability.dart';
import 'package:innovacad_api/src/domain/services/availability_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class AvailabilityServiceImpl implements IAvailabilityService {
  final AvailabilityRepositoryImpl _repository;

  AvailabilityServiceImpl(this._repository);

  @override
  Future<List<Availability>?> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Availability?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Availability?> create(AvailabilityCreateDto dto) async {
    return await _repository.create(dto);
  }

  @override
  Future<Availability?> update(AvailabilityUpdateDto dto) async {
    return await _repository.update(dto);
  }

  @override
  Future<Availability?> delete(String id) async {
    return await _repository.delete(id);
  }
}
