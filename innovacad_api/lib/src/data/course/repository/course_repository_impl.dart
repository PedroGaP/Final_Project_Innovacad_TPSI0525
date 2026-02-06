import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/course/repository/i_course_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

@Repository()
class CourseRepositoryImpl implements ICourseRepository {
  final String table = "courses";
  final String coursesQuerySql = """SELECT
    c.course_id,
    c.identifier,
    c.name,
    cm.module_id,
    cm.courses_modules_id,
    cm.sequence_course_module_id
    FROM courses c
    LEFT JOIN courses_modules cm ON c.course_id = cm.course_id
  """;

  @override
  Future<Result<List<OutputCourseDao>>> getAll() async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final coursesResults = await db.getAll(table: 'courses');

      if (coursesResults.isEmpty) return Result.success([]);

      final courseIds = coursesResults
          .map((c) => "'${c['course_id'].toString().trim()}'")
          .join(',');

      final modulesQuery =
          """
        SELECT 
          cm.courses_modules_id,
          cm.course_id,
          cm.module_id,
          cm.sequence_course_module_id,
          m.name AS module_name, 
          m.duration
        FROM courses_modules cm
        LEFT JOIN modules m ON cm.module_id = m.module_id
        WHERE cm.course_id IN ($courseIds)
      """;

      final modulesResult = await db.query(modulesQuery);

      final Map<String, List<Map<String, dynamic>>> modulesMap = {};

      for (final row in modulesResult.rowsAssoc) {
        final data = row.assoc();

        final cId = data['course_id'].toString().trim().toLowerCase();

        if (!modulesMap.containsKey(cId)) {
          modulesMap[cId] = [];
        }
        modulesMap[cId]!.add(data);
      }

      final List<OutputCourseDao> outputList = coursesResults.map((courseData) {
        final cId = courseData['course_id'].toString().trim().toLowerCase();

        final Map<String, dynamic> fullData = Map.from(courseData);

        final modulesList = modulesMap[cId] ?? [];
        fullData['modules'] = modulesList;

        return OutputCourseDao.fromJson(fullData);
      }).toList();

      return Result.success(outputList);
    } catch (e, s) {
      print("ERRO CRÍTICO: $e");
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error fetching courses",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      final courseResult = await db.getOne(
        table: 'courses',
        where: {"course_id": id},
      );

      if (courseResult.isEmpty) {
        return Result.failure(
          AppError(AppErrorType.notFound, "Course not found"),
        );
      }

      final modulesQuery = """
        SELECT 
          cm.courses_modules_id,
          cm.classes_modules_id,
          cm.course_id,
          cm.module_id,
          cm.sequence_course_module_id,
          m.name AS module_name, 
          m.duration
        FROM courses_modules cm
        LEFT JOIN modules m ON cm.module_id = m.module_id
        WHERE cm.course_id = ?
      """;

      final modulesResult = await db.query(
        modulesQuery,
        whereValues: [id],
        isStmt: true,
      );

      final Map<String, dynamic> fullData = Map.from(courseResult);

      final modulesList = modulesResult.rowsAssoc
          .map((row) => row.assoc())
          .toList();

      fullData['modules'] = modulesList;

      return Result.success(OutputCourseDao.fromJson(fullData));
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the course...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseDao>> create(CreateCourseDto dto) async {
    MysqlUtils? db;
    final uuid = Uuid();

    try {
      db = await MysqlConfiguration.connect();
      await db.startTrans();

      final String newCourseId = uuid.v4();

      await db.insert(
        table: 'courses',
        insertData: {
          "course_id": newCourseId,
          "identifier": dto.identifier,
          "name": dto.name,
        },
      );

      if (dto.addModulesIds != null && dto.addModulesIds!.isNotEmpty) {
        final Map<String, String> moduleToRelationMap = {};
        final insertValues = <String>[];
        final insertParams = <dynamic>[];

        for (final item in dto.addModulesIds!) {
          final newRelationUuid = uuid.v4();

          moduleToRelationMap[item.moduleId] = newRelationUuid;

          insertValues.add("(?, ?, ?, ?)");
          insertParams.addAll([
            newRelationUuid,
            newCourseId,
            item.moduleId,
            null,
          ]);
        }

        if (insertValues.isNotEmpty) {
          final insertSql =
              "INSERT INTO courses_modules (courses_modules_id, course_id, module_id, sequence_course_module_id) VALUES ${insertValues.join(',')}";

          await db.query(insertSql, whereValues: insertParams, isStmt: true);
        }

        final caseCases = <String>[];
        final caseParams = <dynamic>[];
        final idsToUpdate = <String>[];

        for (final item in dto.addModulesIds!) {
          if (item.sequenceModuleId != null) {
            final currentUuid = moduleToRelationMap[item.moduleId];
            final parentUuid = moduleToRelationMap[item.sequenceModuleId];

            if (currentUuid != null && parentUuid != null) {
              caseCases.add("WHEN ? THEN ?");
              caseParams.add(currentUuid);
              caseParams.add(parentUuid);
              idsToUpdate.add("'$currentUuid'");
            }
          }
        }

        if (caseCases.isNotEmpty) {
          final updateSql =
              """
            UPDATE courses_modules 
            SET sequence_course_module_id = CASE courses_modules_id 
            ${caseCases.join(' ')} 
            ELSE sequence_course_module_id 
            END
            WHERE courses_modules_id IN (${idsToUpdate.join(',')})
          """;

          await db.query(updateSql, whereValues: caseParams, isStmt: true);
        }
      }

      await db.commit();

      return await getById(newCourseId);
    } catch (e, s) {
      await db?.rollback();
      print("Error Creating Course: $e");
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error creating course with sequences",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseDao>> update(String id, UpdateCourseDto dto) async {
    MysqlUtils? db;
    final uuid = Uuid();

    try {
      db = await MysqlConfiguration.connect();

      // 1. Check existence
      final existingCourseResult = await getById(id);
      if (existingCourseResult.isFailure || existingCourseResult.data == null) {
        return existingCourseResult;
      }

      await db.startTrans();

      // 2. Update Basic Fields
      final updateData = <String, dynamic>{};
      if (dto.identifier != null) updateData['identifier'] = dto.identifier;
      if (dto.name != null) updateData['name'] = dto.name;

      if (updateData.isNotEmpty) {
        await db.update(
          table: 'courses',
          updateData: updateData,
          where: {"course_id": id},
        );
      }

      // 3. Remove Modules
      if (dto.removeCoursesModules != null &&
          dto.removeCoursesModules!.isNotEmpty) {
        // Safe check for SQL Injection manually since we are injecting into IN (...)
        final idsToRemove = dto.removeCoursesModules!
            .map((e) => "'${e.trim()}'")
            .join(',');

        // Break links first
        await db.query(
          "UPDATE courses_modules SET sequence_course_module_id = NULL WHERE sequence_course_module_id IN ($idsToRemove)",
          isStmt: true,
        );
        // Delete rows
        await db.query(
          "DELETE FROM courses_modules WHERE courses_modules_id IN ($idsToRemove)",
          isStmt: true,
        );
      }

      // 4. Add Modules
      if (dto.addCoursesModules != null && dto.addCoursesModules!.isNotEmpty) {
        // Fetch current state using transaction connection
        final currentRows = await db.query(
          "SELECT courses_modules_id, module_id FROM courses_modules WHERE course_id = ?",
          whereValues: [id],
          isStmt: true,
        );

        final Map<String, String> moduleToRelationMap = {
          for (var row in currentRows.rowsAssoc)
            row.assoc()['module_id'].toString().trim().toLowerCase(): row
                .assoc()['courses_modules_id']
                .toString(),
        };

        // Determine what needs to be inserted
        final newModulesToInsert = <String>[];
        for (var item in dto.addCoursesModules!) {
          // If we don't have this module ID linked to this course yet, we need to insert it
          if (!moduleToRelationMap.containsKey(
            item.moduleId.trim().toLowerCase(),
          )) {
            newModulesToInsert.add(item.moduleId);
          }
        }

        // Perform Inserts
        if (newModulesToInsert.isNotEmpty) {
          final insertValues = <String>[];
          final insertParams = <dynamic>[];

          for (final modId in newModulesToInsert) {
            final newRelationUuid = uuid.v4();
            // Add to map immediately so we can use it for sequencing below
            moduleToRelationMap[modId.trim().toLowerCase()] = newRelationUuid;

            insertValues.add("(?, ?, ?, ?)");
            insertParams.addAll([newRelationUuid, id, modId, null]);
          }

          final insertSql =
              "INSERT INTO courses_modules (courses_modules_id, course_id, module_id, sequence_course_module_id) VALUES ${insertValues.join(',')}";
          await db.query(insertSql, whereValues: insertParams, isStmt: true);
        }

        // 5. Update Sequences (The fix for Error 1020)
        for (final item in dto.addCoursesModules!) {
          final modKey = item.moduleId.trim().toLowerCase();
          final currentUuid = moduleToRelationMap[modKey];

          if (currentUuid == null) continue;

          if (item.sequenceModuleId != null) {
            final seqKey = item.sequenceModuleId!.trim().toLowerCase();
            final parentUuid = moduleToRelationMap[seqKey];

            if (parentUuid != null) {
              // FIX: Use raw query instead of db.update to avoid optimistic lock check on dirty rows
              await db.query(
                "UPDATE courses_modules SET sequence_course_module_id = ? WHERE courses_modules_id = ?",
                whereValues: [parentUuid, currentUuid],
                isStmt: true,
              );
            }
          } else {
            // Set to null
            await db.query(
              "UPDATE courses_modules SET sequence_course_module_id = NULL WHERE courses_modules_id = ?",
              whereValues: [currentUuid],
              isStmt: true,
            );
          }
        }
      }

      await db.commit();
      return await getById(id);
    } catch (e, s) {
      await db?.rollback();
      print("Update Error: $e");
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error updating course",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<OutputCourseDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingCourse = await getById(id);

      print(existingCourse.data.toString());
      print(id);

      if (existingCourse.isFailure || existingCourse.data == null)
        return existingCourse;

      db = await MysqlConfiguration.connect();

      await db.delete(table: table, where: {"course_id": id});

      return existingCourse;
    } catch (e, s) {
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while deleting the course...",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    }
  }
}
