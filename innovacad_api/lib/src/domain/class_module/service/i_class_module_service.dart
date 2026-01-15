import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/class_module/dao/output/output_class_module_dao.dart';
import 'package:innovacad_api/src/data/class_module/dto/create/create_class_module_dto.dart';
import 'package:innovacad_api/src/data/class_module/dto/delete/delete_class_module_dto.dart';
import 'package:innovacad_api/src/data/class_module/dto/update/update_class_module_dto.dart';

abstract class IClassModuleService {
  Future<Result<List<OutputClassModuleDao>>> getAll();
  Future<Result<OutputClassModuleDao>> getById(String id);
  Future<Result<OutputClassModuleDao>> create(CreateClassModuleDto dto);
  Future<Result<OutputClassModuleDao>> update(UpdateClassModuleDto dto);
  Future<Result<OutputClassModuleDao>> delete(DeleteClassModuleDto dto);
}
