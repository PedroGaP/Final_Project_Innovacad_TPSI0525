import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/class_model/dao/output/output_class_dao.dart';
import 'package:innovacad_api/src/data/class_model/dto/create/create_class_dto.dart';
import 'package:innovacad_api/src/data/class_model/dto/delete/delete_class_dto.dart';
import 'package:innovacad_api/src/data/class_model/dto/update/update_class_dto.dart';

abstract class IClassService {
  Future<Result<List<OutputClassDao>>> getAll();
  Future<Result<OutputClassDao>> getById(String id);
  Future<Result<OutputClassDao>> create(CreateClassDto dto);
  Future<Result<OutputClassDao>> update(UpdateClassDto dto);
  Future<Result<OutputClassDao>> delete(DeleteClassDto dto);
}
