import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/class_module/dto/link/link_class_module_dto.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/domain.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Repository()
class ClassRepositoryImpl implements IClassRepository {
  final String table = "classes";

  @override
  Future<Result<List<OutputClassDao>>> getAll() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final query = """
          SELECT c.*, CONCAT(co.identifier, ' ', c.identifier) AS identifier, co.identifier AS course_identifier
          FROM classes c
          JOIN courses co ON c.course_id = co.course_id
        """;

        final classesResults = await db.query(query);

        if (classesResults.numOfRows < 1) {
          return Result.success([]);
        }

        final classesList = classesResults.rowsAssoc
            .map((r) => r.assoc())
            .toList();

        final classIdsString = classesList
            .map((c) => "'${c['class_id'].toString()}'")
            .join(',');

        final modulesQuery =
            """
          SELECT 
            cm.classes_modules_id,
            crm.courses_modules_id,
            cm.class_id,
            cm.current_duration,
            crm.sequence_course_module_id,
            cm.trainer_id,
            u.name as trainer_name,
            m.module_id,
            m.name AS module_name,
            m.duration as total_duration
          FROM classes_modules cm
          JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
          JOIN modules m ON crm.module_id = m.module_id
          LEFT JOIN trainers t ON cm.trainer_id = t.trainer_id
          LEFT JOIN user u ON t.user_id = u.id
          WHERE cm.class_id IN ($classIdsString)
          ORDER BY crm.sequence_course_module_id ASC
        """;

        final modulesResult = await db.query(modulesQuery, debug: false);

        final Map<String, List<Map<String, dynamic>>> modulesByClassId = {};

        for (final row in modulesResult.rowsAssoc) {
          final data = row.assoc();
          final cId = data['class_id'].toString().trim().toLowerCase();

          if (!modulesByClassId.containsKey(cId)) {
            modulesByClassId[cId] = [];
          }

          final moduleData = Map<String, dynamic>.from(data);
          if (moduleData['sequence_class_module_id'] == null)
            moduleData['sequence_class_module_id'] = null;
          if (moduleData['trainer_id'] == null) moduleData['trainer_id'] = null;
          if (moduleData['trainer_name'] == null)
            moduleData['trainer_name'] = null;

          modulesByClassId[cId]!.add(moduleData);
        }

        final List<OutputClassDao> outputList = classesList.map((classData) {
          final classId = classData['class_id'].toString().trim().toLowerCase();

          final Map<String, dynamic> fullData = Map.from(classData);
          fullData['modules'] = modulesByClassId[classId] ?? [];

          return OutputClassDao.fromJson(fullData);
        }).toList();

        return Result.success(outputList);
      });
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
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
        final query = """
          SELECT c.*, CONCAT(co.identifier, ' ', c.identifier) AS identifier, co.identifier AS course_identifier
          FROM classes c
          JOIN courses co ON c.course_id = co.course_id
          WHERE c.class_id = ?
        """;

        final classResult = await db.query(
          query,
          whereValues: [id],
          isStmt: true,
        );

        if (classResult.numOfRows < 1) {
          return Result.failure(
            AppError(AppErrorType.notFound, "Class not found"),
          );
        }

        final modulesQuery = """
          SELECT 
            cm.classes_modules_id,
            crm.courses_modules_id,
            cm.class_id,
            cm.current_duration,
            crm.sequence_course_module_id,
            cm.trainer_id,
            u.name as trainer_name,
            m.module_id,
            m.name AS module_name,
            m.duration as total_duration
          FROM classes_modules cm
          JOIN courses_modules crm ON cm.courses_modules_id = crm.courses_modules_id
          JOIN modules m ON crm.module_id = m.module_id
          LEFT JOIN trainers t ON cm.trainer_id = t.trainer_id
          LEFT JOIN user u ON t.user_id = u.id
          WHERE cm.class_id = ?
          ORDER BY crm.sequence_course_module_id ASC
        """;

        final modulesResult = await db.query(
          modulesQuery,
          whereValues: [id],
          isStmt: true,
        );

        final Map<String, dynamic> fullData = Map.from(
          classResult.rowsAssoc.first.assoc(),
        );

        fullData['modules'] = modulesResult.rowsAssoc.map((row) {
          final m = row.assoc();
          if (m['sequence_class_module_id'] == null)
            m['sequence_class_module_id'] = null;
          if (m['trainer_id'] == null) m['trainer_id'] = null;
          if (m['trainer_name'] == null) m['trainer_name'] = null;
          return m;
        }).toList();

        return Result.success(OutputClassDao.fromJson(fullData));
      });
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching class",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputClassDao>> create(CreateClassDto dto) async {
    MysqlUtils? db;
    final uuidGenerator = Uuid();

    try {
      db = await MysqlConfiguration.getConnection();
      await db.startTrans();

      final String newClassId = uuidGenerator.v4();

      await db.insert(
        table: 'classes',
        insertData: {
          "class_id": newClassId,
          "course_id": dto.courseId,
          "location": dto.location,
          "identifier": dto.identifier,
          "status": dto.status.name,
          "start_date_timestamp": dto.startDateTimestamp.toIso8601String(),
          "end_date_timestamp": dto.endDateTimestamp.toIso8601String(),
        },
      );

      if (dto.modules != null && dto.modules!.isNotEmpty) {
        for (final LinkClassModuleDto item in dto.modules!) {
          final String linkId = uuidGenerator.v4();

          await db.insert(
            table: 'classes_modules',
            insertData: {
              'classes_modules_id': linkId,
              'class_id': newClassId,
              'courses_modules_id': item.courseModuleId,
              'trainer_id': item.trainerId,
              'current_duration': 0,
            },
          );
        }
      }

      await db.commit();

      final klass = await getById(newClassId);

      if (klass.isFailure)
        throw Exception("Class created but failed to fetch result");

      return klass;
    } catch (e, s) {
      if (db != null) await db.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error creating class",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputClassDao>> update(String id, UpdateClassDto dto) async {
    MysqlUtils? db;

    try {
      final existingClassResult = await getById(id);
      if (existingClassResult.isFailure || existingClassResult.data == null) {
        return existingClassResult;
      }

      db = await MysqlConfiguration.getConnection();
      await db.startTrans();

      final updateData = <String, dynamic>{};
      final existingData = existingClassResult.data!;

      if (dto.courseId != null && dto.courseId != existingData.courseId)
        updateData["course_id"] = dto.courseId;
      if (dto.location != null && dto.location != existingData.location)
        updateData["location"] = dto.location;
      if (dto.identifier != null && dto.identifier != existingData.identifier)
        updateData["identifier"] = dto.identifier;
      if (dto.status != null && dto.status!.name != existingData.status.name)
        updateData["status"] = dto.status!.name;

      if (dto.startDateTimestamp != null &&
          dto.startDateTimestamp != existingData.startDateTimestamp)
        updateData["start_date_timestamp"] = dto.startDateTimestamp!
            .toIso8601String();

      if (dto.endDateTimestamp != null &&
          dto.endDateTimestamp != existingData.endDateTimestamp)
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

      if (dto.addModules != null && dto.addModules!.isNotEmpty) {
        final currentModulesResult = await db.query(
          "SELECT classes_modules_id, courses_modules_id FROM classes_modules WHERE class_id = ?",
          whereValues: [id],
          isStmt: true,
        );

        final Map<String, String> existingMap = {
          for (var row in currentModulesResult.rowsAssoc)
            row.assoc()['courses_modules_id'].toString().trim(): row
                .assoc()['classes_modules_id']
                .toString(),
        };

        for (final item in dto.addModules!) {
          final courseModId = item.courseModuleId.trim();
          final trainerId = item.trainerId;

          if (existingMap.containsKey(courseModId)) {
            final pkId = existingMap[courseModId];

            await db.query(
              "UPDATE classes_modules SET trainer_id = ? WHERE classes_modules_id = ?",
              whereValues: [trainerId, pkId],
              isStmt: true,
            );
          } else {
            await db.insert(
              table: 'classes_modules',
              insertData: {
                "class_id": id,
                "courses_modules_id": courseModId,
                "trainer_id": trainerId,
                "current_duration": 0,
              },
            );
          }
        }
      }

      await db.commit();

      return await getById(id);
    } catch (e, s) {
      if (db != null) await db.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while updating the class...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputClassDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingClass = await getById(id);

      if (existingClass.isFailure || existingClass.data == null)
        return existingClass;

      db = await MysqlConfiguration.getConnection();

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
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }
}
