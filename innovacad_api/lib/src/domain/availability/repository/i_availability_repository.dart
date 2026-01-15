import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/availability/dao/output/output_availability_dao.dart';
import 'package:innovacad_api/src/data/availability/dto/create/create_availability_dto.dart';
import 'package:innovacad_api/src/data/availability/dto/delete/delete_availability_dto.dart';
import 'package:innovacad_api/src/data/availability/dto/update/update_availability_dto.dart';

abstract class IAvailabilityRepository {
  Future<Result<List<OutputAvailabilityDao>>> getAll();
  Future<Result<OutputAvailabilityDao>> getById(String id);
  Future<Result<OutputAvailabilityDao>> create(CreateAvailabilityDto dto);
  Future<Result<OutputAvailabilityDao>> update(UpdateAvailabilityDto dto);
  Future<Result<OutputAvailabilityDao>> delete(DeleteAvailabilityDto dto);
}
