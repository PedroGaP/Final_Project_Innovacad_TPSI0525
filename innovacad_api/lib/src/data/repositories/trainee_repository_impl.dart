import 'dart:developer';

import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/api/utils/update_utils.dart';
import 'package:innovacad_api/src/core/result.dart';
import 'package:innovacad_api/src/domain/daos/trainee_user_dao.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_create_dto.dart';
import 'package:innovacad_api/src/domain/dtos/trainee/trainee_user_update_dto.dart';
import 'package:innovacad_api/src/domain/repositories/trainee_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class TraineeRepositoryImpl implements ITraineeRepository {
  final String table = "trainees";
  final String traineeUserTable = "trainees t,user u";
  final String traineeUserFields =
      "t.*, u.id, u.name, u.image, u.role, u.username, u.email, u.createdAt";

  @override
  Future<Result<List<TraineeUserDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      List<Map<String, dynamic>> tempTrainees = (await db.getAll(
        table: traineeUserTable,
        where: "u.id = t.user_id",
        fields: traineeUserFields,
      )).cast();

      print(tempTrainees);

      if (tempTrainees.isEmpty) {
        return Result.success<List<TraineeUserDao>>([]);
      }

      final trainees = tempTrainees
          .map((e) => TraineeUserDao.fromJson(e))
          .toList()
          .cast<TraineeUserDao>();

      return Result.success<List<TraineeUserDao>>(trainees);
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      print("ass");
      return Result.failure<List<TraineeUserDao>>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<TraineeUserDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      Map<String, dynamic> tempTrainee = (await db.getOne(
        table: traineeUserTable,
        where: {'trainee_id': id},
        fields: traineeUserFields,
        debug: true,
      )).cast();

      print(tempTrainee);

      if (tempTrainee.isEmpty)
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.notFound, 'Trainee not found'),
        );

      final trainee = TraineeUserDao.fromJson(tempTrainee);
      return Result.success<TraineeUserDao>(trainee);
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return Result.failure<TraineeUserDao>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<TraineeUserDao>> create(TraineeCreateDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      BigInt insert = await db.insert(table: table, insertData: dto.toJson());

      if (insert < BigInt.from(1))
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.internal, 'Insert failed'),
        );

      final fetched = await getById(insert.toString());
      if (fetched.isFailure) {
        return Result.failure<TraineeUserDao>(
          AppError(
            AppErrorType.internal,
            'Insert succeeded but could not fetch created trainee',
            details: {
              'insertId': insert.toString(),
              'error': fetched.error?.message,
            },
          ),
        );
      }

      return Result.success<TraineeUserDao>(fetched.data!);
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return Result.failure<TraineeUserDao>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<TraineeUserDao>> update(
    String id,
    TraineeUserUpdateDto dto,
  ) async {
    MysqlUtils? conn;
    try {
      conn = await MysqlConfiguration.connect();

      final existingRes = await getById(id);
      if (existingRes.isFailure)
        return Result.failure<TraineeUserDao>(existingRes.error!);

      final tempClass = existingRes.data!;

      final data = UpdateUtils.patchModel(tempClass.toJson(), dto.toJson());

      if (data.updatedFields.length == 0)
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.badRequest, 'No fields to update'),
        );

      data.patchedModel.addAll({'updatedAt': DateTime.now()});

      print('[PatchedModel] ${data.patchedModel}');
      print('[DTO] ${dto.toJson()}');
      print('[GetById Trainee] ${existingRes.data?.toJson() ?? "Vazio"}');

      final update = await conn.update(
        table: traineeUserTable,
        updateData: data.updatedFields,
        where: {'trainee_id': id},
      );

      if (update < BigInt.from(1))
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.internal, 'Update failed'),
        );

      final updated = TraineeUserDao.fromJson(data.patchedModel);
      return Result.success<TraineeUserDao>(updated);
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      return Result.failure<TraineeUserDao>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<TraineeUserDao>> delete(String id) async {
    MysqlUtils? conn;
    try {
      conn = await MysqlConfiguration.connect();

      final existingRes = await getById(id);
      if (existingRes.isFailure)
        return Result.failure<TraineeUserDao>(existingRes.error!);

      final tempClass = existingRes.data!;

      BigInt deleted = await conn.delete(
        table: table,
        where: {'trainee_id': id},
      );

      if (deleted == BigInt.zero)
        return Result.failure<TraineeUserDao>(
          AppError(AppErrorType.internal, 'Delete failed'),
        );

      return Result.success<TraineeUserDao>(tempClass);
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
      return Result.failure<TraineeUserDao>(
        AppError(
          AppErrorType.external,
          'Database error',
          details: {'error': e.toString()},
        ),
      );
    }
  }
}
