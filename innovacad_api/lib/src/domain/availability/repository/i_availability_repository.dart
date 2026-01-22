import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';

abstract class IAvailabilityRepository {
  Future<Result<List<OutputAvailabilityDao>>> getAll();
  Future<Result<OutputAvailabilityDao>> getById(String id);
  Future<Result<OutputAvailabilityDao>> create(CreateAvailabilityDto dto);
  Future<Result<OutputAvailabilityDao>> update(
    String id,
    UpdateAvailabilityDto dto,
  );
  Future<Result<OutputAvailabilityDao>> delete(String id);
}
