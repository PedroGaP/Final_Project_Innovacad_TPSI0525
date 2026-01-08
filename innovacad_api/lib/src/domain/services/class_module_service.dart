import 'package:innovacad_api/src/domain/dtos/class_module/class_module_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_module/class_module_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/class_module.dart';

abstract interface class IClassModuleService {
  Future<List<ClassModule>?> getAll();
  Future<ClassModule?> getById(String id);
  Future<ClassModule?> create(ClassModuleCreateDto dto);
  Future<ClassModule?> update(ClassModuleUpdateDto dto);
  Future<ClassModule?> delete(String id);
}
