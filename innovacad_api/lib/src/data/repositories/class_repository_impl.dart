import 'dart:developer';

import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/api/utils/update_utils.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/class_model/class_model_update_dto.dart';
import 'package:innovacad_api/src/domain/entities/class_model.dart';
import 'package:innovacad_api/src/domain/repositories/class_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ClassRepositoryImpl implements IClassRepository {
  final MysqlConfiguration mysql;

  ClassRepositoryImpl(this.mysql);

  @override
  Future<List<ClassModel>?> getAll() async {
    MysqlUtils? conn = null;
    List<ClassModel>? classesModel;
    try {
      conn = await MysqlConfiguration.connect();

      List<Map<String, dynamic>> classes = (await conn.getAll(
        table: 'classes',
      )).cast<Map<String, dynamic>>();

      classesModel = classes
          .map(ClassModel.fromJson)
          .cast<ClassModel>()
          .toList();
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    } finally {
      return classesModel;
    }
  }

  @override
  Future<ClassModel?> getById(String id) async {
    MysqlUtils? conn = null;
    ClassModel? model;
    try {
      conn = await MysqlConfiguration.connect();

      Map<String, dynamic> klass = (await conn.getOne(
        table: 'classes',
        where: {'class_id': id},
      )).cast<String, dynamic>();

      if (klass.isEmpty) return null;

      model = ClassModel.fromJson(klass);
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    } finally {
      return model;
    }
  }

  @override
  Future<ClassModel?> create(ClassModelCreateDto dto) async {
    MysqlUtils? conn;
    ClassModel? model;

    try {
      conn = await MysqlConfiguration.connect();

      BigInt inserted = await conn.insert(
        table: 'classes',
        insertData: dto.toJson(),
      );

      if (inserted == 0) return null;

      model = ClassModel.fromJson(dto.toJson());
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    } finally {
      return model;
    }
  }

  @override
  Future<ClassModel?> update(String id, ClassModelUpdateDto dto) async {
    MysqlUtils? conn;
    ClassModel? model;

    try {
      conn = await MysqlConfiguration.connect();

      ClassModel? tempClass = await this.getById(id);
      if (tempClass == null) return model;

      final data = UpdateUtils.patchModel(tempClass.toJson(), dto.toJson());
      print("Patched: ${data.patchedModel}\nTo update: ${data.updatedFields}");

      if (data.updatedFields.length == 0) return model;

      final update = await conn.update(
        table: 'classes',
        updateData: data.patchedModel,
        where: {'class_id': id},
      );

      if (update.toInt() == 0) return model;

      model = ClassModel.fromJson(data.patchedModel);
      print(model);
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
    } finally {
      return model;
    }
  }

  @override
  Future<ClassModel?> delete(String id) async {
    MysqlUtils? conn;
    ClassModel? model;

    try {
      conn = await MysqlConfiguration.connect();

      ClassModel? tempClass = await this.getById(id);

      if (tempClass == null)
        throw "[UPDATE]: Something went wrong fetching the class data!";

      BigInt delete = await conn.delete(
        table: 'classes',
        where: {'class_id': id},
      );

      if (delete == 0) return null;
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    } finally {
      conn?.close();
      return model;
    }
  }
}
