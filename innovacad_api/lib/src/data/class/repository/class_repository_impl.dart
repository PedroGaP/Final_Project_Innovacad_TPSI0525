import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ClassRepositoryImpl implements IClassRepository {
  final String table = "classes";

  @override
  Future<Result<List<OutputClassDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();

      final classesResults = await db.getAll(table: 'classes');

      final List<OutputClassDao> outputList = [];

      for (final classData in classesResults) {
        final classId = classData['class_id'];

        final modulesResult = await db.query(
          "SELECT courses_modules_id, classes_modules_id, current_duration FROM classes_modules WHERE class_id = ?",
          whereValues: [classId],
          isStmt: true,
        );

        final Map<String, dynamic> fullData = Map.from(classData);

        fullData['modules'] = modulesResult.rowsAssoc
            .map(
              (row) => {
                "classes_modules_id": row.assoc()['classes_modules_id'],
                "courses_modules_id": row.assoc()['courses_modules_id'],
                "current_duration": row.assoc()['current_duration'],
              },
            )
            .toList();

        outputList.add(OutputClassDao.fromJson(fullData));
      }

      return Result.success(outputList);
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the classes...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final classResult = await db.getOne(
        table: 'classes',
        where: {"class_id": id},
      );

      if (classResult.isEmpty) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Class not found"),
        );
      }

      final modulesResult = await db.query(
        "SELECT courses_modules_id, current_duration FROM classes_modules WHERE class_id = ?",
        whereValues: [id],
        isStmt: true,
      );

      final Map<String, dynamic> fullData = Map.from(classResult);

      fullData['modules'] = modulesResult.rowsAssoc.map((row) {
        return {
          "classes_modules_id": row.assoc()['classes_modules_id'],
          "courses_modules_id": row.assoc()['courses_modules_id'],
          "current_duration": row.assoc()['current_duration'],
        };
      }).toList();

      return Result.success(OutputClassDao.fromJson(fullData));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the class...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> create(CreateClassDto dto) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();
      await db.startTrans();

      await db.insert(
        table: 'classes',
        insertData: {
          "course_id": dto.courseId,
          "location": dto.location,
          "identifier": dto.identifier,
          "status": dto.status.name,
          "start_date_timestamp": dto.startDateTimestamp.toIso8601String(),
          "end_date_timestamp": dto.endDateTimestamp.toIso8601String(),
        },
      );

      final createdClass = await db.getOne(
        table: 'classes',
        where: {"identifier": dto.identifier},
      );

      if (createdClass.isEmpty) throw Exception("Class creation failed");
      final String newClassId = createdClass['class_id'];

      if (dto.modulesIds != null && dto.modulesIds!.isNotEmpty) {
        for (final String courseModuleId in dto.modulesIds!) {
          await db.insert(
            table: 'classes_modules',
            insertData: {
              'class_id': newClassId,
              'courses_modules_id': courseModuleId,
              'current_duration': 0,
            },
          );
        }
      }

      await db.commit();

      final klass = await getById(newClassId);
      if (klass.isFailure) throw Exception("Class creation failed");

      final createdClassMap = klass.data!.toJson();

      print(createdClassMap);

      return Result.success(OutputClassDao.fromJson(createdClassMap));
    } catch (e, s) {
      await db?.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error creating class",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> update(String id, UpdateClassDto dto) async {
    MysqlUtils? db;

    print(dto.toJson());
    print(dto.removeClassesModulesIds);

    try {
      db = await MysqlConfiguration.connect();

      final existingClassResult = await getById(id);
      if (existingClassResult.isFailure || existingClassResult.data == null) {
        return existingClassResult;
      }
      final existingClass = existingClassResult.data!;

      await db.startTrans();

      final updateData = <String, dynamic>{};

      if (dto.courseId != null && dto.courseId != existingClass.courseId)
        updateData["course_id"] = dto.courseId;

      if (dto.location != null && dto.location != existingClass.location)
        updateData["location"] = dto.location;

      if (dto.identifier != null && dto.identifier != existingClass.identifier)
        updateData["identifier"] = dto.identifier;

      if (dto.status != null && dto.status!.name != existingClass.status.name)
        updateData["status"] = dto.status!.name;

      if (dto.startDateTimestamp != null &&
          dto.startDateTimestamp != existingClass.startDateTimestamp)
        updateData["start_date_timestamp"] = dto.startDateTimestamp!
            .toIso8601String();

      if (dto.endDateTimestamp != null &&
          dto.endDateTimestamp != existingClass.endDateTimestamp)
        updateData["end_date_timestamp"] = dto.endDateTimestamp!
            .toIso8601String();

      if (updateData.isNotEmpty) {
        await db.update(
          table: 'classes',
          updateData: updateData,
          where: {"class_id": id},
        );
      }

      if (dto.removeClassesModulesIds != null &&
          dto.removeClassesModulesIds!.isNotEmpty) {
        for (final idToRemove in dto.removeClassesModulesIds!) {
          await db.delete(
            table: 'classes_modules',
            where: {"class_id": id, "courses_modules_id": idToRemove},
          );
        }
      }

      if (dto.addModulesIds != null && dto.addModulesIds!.isNotEmpty) {
        final currentModulesResult = await db.query(
          "SELECT courses_modules_id FROM classes_modules WHERE class_id = ?",
          whereValues: [id],
          isStmt: true,
        );

        final Set<String> existingModuleIds = currentModulesResult.rowsAssoc
            .map((row) => row.assoc()['courses_modules_id'].toString())
            .toSet();

        for (final idToAdd in dto.addModulesIds!) {
          if (!existingModuleIds.contains(idToAdd)) {
            await db.insert(
              table: 'classes_modules',
              insertData: {
                "class_id": id,
                "courses_modules_id": idToAdd,
                "current_duration": 0,
              },
            );
          }
        }
      }

      await db.commit();

      return await getById(id);
    } catch (e, s) {
      await db?.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the class...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingClass = await getById(id);

      if (existingClass.isFailure || existingClass.data == null)
        return existingClass;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"class_id": id});

      return existingClass;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the class...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }
}
