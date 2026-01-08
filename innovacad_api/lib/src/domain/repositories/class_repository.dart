import 'package:innovacad_api/src/domain/dtos/class_model/class_model_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/class_model.dart';

abstract interface class IClassRepository {
  Future<List<ClassModel>?> getAll();
  Future<ClassModel?> getById(String id);
  Future<ClassModel?> create(ClassModelCreateDto dto);
  Future<ClassModel?> update(ClassModelUpdateDto dto);
  Future<ClassModel?> delete(String id);
}
