import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/availability/repository/i_availability_repository.dart';
import 'package:innovacad_api/src/domain/availability/service/i_availability_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class AvailabilityServiceImpl implements IAvailabilityService {
  final IAvailabilityRepository _repository;

  AvailabilityServiceImpl(this._repository);

  @override
  Future<Result<List<OutputAvailabilityDao>>> getAll() async => _repository.getAll();

  @override
  Future<Result<OutputAvailabilityDao>> getById(String id) async => _repository.getById(id);

  @override
  Future<Result<OutputAvailabilityDao>> create(CreateAvailabilityDto dto) async => _repository.create(dto);

  @override
  Future<Result<OutputAvailabilityDao>> update(UpdateAvailabilityDto dto) async => _repository.update(dto);

  @override
  Future<Result<OutputAvailabilityDao>> delete(DeleteAvailabilityDto dto) async => _repository.delete(dto);
}
