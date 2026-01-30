import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:innovacad_api/src/domain/trainer/repository/i_trainer_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart' as v;

@v.Repository()
class TrainerRepositoryImpl implements ITrainerRepository {
  final RemoteUserService _remoteUserService;
  final String table = "trainers";

  TrainerRepositoryImpl(this._remoteUserService);

  @override
  Future<Result<List<OutputTrainerDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final query = """
        SELECT t.trainer_id, t.user_id, t.birthday_date, 
               u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt, u.emailVerified 
        FROM `trainers` t 
        JOIN `user` u ON t.user_id = u.id
      """;
      final results = await db.query(query);
      final List<OutputTrainerDao> daos = [];

      for (var row in results.rows) {
        final skillQuery =
            "SELECT module_id, competence_level FROM trainer_skills WHERE trainer_id = ?";
        final skillResults = await db.query(
          skillQuery,
          whereValues: [row['trainer_id']],
          isStmt: true,
        );

        row['skills'] = skillResults.rows;
        daos.add(OutputTrainerDao.fromJson(row));
      }

      return Result.success(daos);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          e.toString(),
          details: {"stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputTrainerDao>> getById(String trainerId) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final results = await db.query(
        "SELECT t.trainer_id, t.user_id, t.birthday_date, u.id, u.username, u.name, u.email, u.role, u.image, u.createdAt, u.emailVerified "
        "FROM `trainers` t JOIN `user` u ON t.user_id = u.id WHERE t.trainer_id = ? LIMIT 1",
        whereValues: [trainerId],
        isStmt: true,
      );

      if (results.rows.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "Trainer not found"),
        );

      final trainerMap = results.rows[0];
      final skillResults = await db.query(
        "SELECT module_id, competence_level FROM trainer_skills WHERE trainer_id = ?",
        whereValues: [trainerId],
        isStmt: true,
      );

      trainerMap['skills'] = skillResults.rows;
      return Result.success(OutputTrainerDao.fromJson(trainerMap));
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTrainerDao>> create(CreateTrainerDto dto) async {
    MysqlUtils? db;
    String? createdUserId;
    try {
      final responseUser = await _remoteUserService.signUpUser(
        dto.email,
        dto.name,
        dto.password,
      );
      if (responseUser.isFailure) return Result.failure(responseUser.error!);

      final userData = responseUser.data as Map<String, dynamic>;
      createdUserId = userData["id"];

      db = await MysqlConfiguration.connect();
      await db.startTrans();

      await db.update(
        table: "user",
        updateData: {"username": dto.username, "role": "trainer"},
        where: {"id": createdUserId},
      );

      final trainerId = Uuid().toString();
      await db.insert(
        table: table,
        insertData: {
          "trainer_id": trainerId,
          "user_id": createdUserId,
          "birthday_date": dto.birthdayDate,
        },
      );

      if (dto.skillsToAdd != null) {
        for (var skill in dto.skillsToAdd!) {
          await db.insert(
            table: "trainer_skills",
            insertData: {
              "trainer_id": trainerId,
              "module_id": skill.moduleId,
              "competence_level": skill.competenceLevel ?? 1,
            },
          );
        }
      }

      await db.commit();
      return await getById(trainerId);
    } catch (e) {
      if (db != null) await db.rollback();
      if (createdUserId != null)
        await _remoteUserService.deleteUserAsAdmin(createdUserId);
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTrainerDao>> update(
    String trainerId,
    UpdateTrainerDto dto,
  ) async {
    MysqlUtils? db;
    try {
      final res = await getById(trainerId);
      if (res.isFailure) return res;

      await _remoteUserService.updateUser(res.data!.id, dto);

      db = await MysqlConfiguration.connect();
      await db.startTrans();

      if (dto.birthdayDate != null) {
        await db.update(
          table: table,
          updateData: {"birthday_date": dto.birthdayDate},
          where: {"trainer_id": trainerId},
        );
      }

      if (dto.skillsToRemove != null && dto.skillsToRemove!.isNotEmpty) {
        final ids = dto.skillsToRemove!
            .split(',')
            .map((e) => e.trim())
            .toList();
        final placeholders = ids.map((_) => "?").join(",");
        await db.query(
          "DELETE FROM trainer_skills WHERE trainer_id = ? AND module_id IN ($placeholders)",
          whereValues: [trainerId, ...ids],
          isStmt: true,
        );
      }

      if (dto.skillsToAdd != null) {
        for (var skill in dto.skillsToAdd!) {
          await db.query(
            "INSERT INTO trainer_skills (trainer_id, module_id, competence_level) "
            "VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE competence_level = ?",
            whereValues: [
              trainerId,
              skill.moduleId,
              skill.competenceLevel ?? 1,
              skill.competenceLevel ?? 1,
            ],
            isStmt: true,
          );
        }
      }

      await db.commit();

      return await getById(trainerId);
    } catch (e) {
      if (db != null) await db.rollback();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputTrainerDao>> delete(String id) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(id);
      if (existingRes.isFailure) return existingRes;

      await _remoteUserService.deleteUserAsAdmin(existingRes.data!.id);

      db = await MysqlConfiguration.connect();
      await db.startTrans();

      await db.delete(table: "user", where: {"id": existingRes.data!.id});

      await db.commit();
      return existingRes;
    } catch (e) {
      if (db != null) await db.rollback();
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
