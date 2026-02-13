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
    c.area,
    cm.module_id,
    cm.courses_modules_id,
    cm.sequence_course_module_id
    FROM courses c
    LEFT JOIN courses_modules cm ON c.course_id = cm.course_id
  """;

  @override
  Future<Result<List<OutputCourseDao>>> getAll() async {
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
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

        final List<OutputCourseDao> outputList = coursesResults.map((
          courseData,
        ) {
          final cId = courseData['course_id'].toString().trim().toLowerCase();

          final Map<String, dynamic> fullData = Map.from(courseData);

          final modulesList = modulesMap[cId] ?? [];
          fullData['modules'] = modulesList;

          return OutputCourseDao.fromJson(fullData);
        }).toList();

        return Result.success(outputList);
      });
    } catch (e, s) {
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
    try {
      return await MysqlConfiguration.executeWithConnection((db) async {
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
          SELECT cm.courses_modules_id,
              cms.classes_modules_id,
              cm.course_id,
              cm.module_id,
              cm.sequence_course_module_id,
              m.name AS module_name,
              m.duration
          FROM courses_modules cm
              LEFT JOIN modules m ON cm.module_id = m.module_id
              LEFT JOIN classes_modules cms ON cms.courses_modules_id = cm.courses_modules_id
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
      });
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
      db = await MysqlConfiguration.getConnection();
      await db.startTrans();

      final String newCourseId = uuid.v4();

      await db.insert(
        table: 'courses',
        insertData: {
          "course_id": newCourseId,
          "identifier": dto.identifier,
          "name": dto.name,
          "area": dto.area,
        },
      );

      if (dto.addModulesIds != null && dto.addModulesIds!.isNotEmpty) {
        final Map<String, String> moduleToRelationMap = {};

        for (final item in dto.addModulesIds!) {
          moduleToRelationMap[item.moduleId] = uuid.v4();
        }

        final insertValues = <String>[];
        final insertParams = <dynamic>[];

        for (final item in dto.addModulesIds!) {
          final currentUuid = moduleToRelationMap[item.moduleId];

          String? sequenceUuid;
          if (item.sequenceModuleId != null) {
            sequenceUuid = moduleToRelationMap[item.sequenceModuleId];
          }

          insertValues.add("(?, ?, ?, ?)");
          insertParams.addAll([
            currentUuid,
            newCourseId,
            item.moduleId,
            sequenceUuid,
          ]);
        }

        if (insertValues.isNotEmpty) {
          final insertSql =
              "INSERT INTO courses_modules (courses_modules_id, course_id, module_id, sequence_course_module_id) VALUES ${insertValues.join(',')}";

          await db.query(insertSql, whereValues: insertParams, isStmt: true);
        }
      }

      await db.commit();
      return await getById(newCourseId);
    } catch (e, s) {
      if (db != null) await db.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error creating course",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputCourseDao>> update(String id, UpdateCourseDto dto) async {
    MysqlUtils? db;
    final uuid = Uuid();

    try {
      final existingCourseResult = await getById(id);
      if (existingCourseResult.isFailure || existingCourseResult.data == null) {
        return existingCourseResult;
      }

      db = await MysqlConfiguration.getConnection();
      await db.startTrans();

      final updateData = <String, dynamic>{};
      if (dto.identifier != null) updateData['identifier'] = dto.identifier;
      if (dto.name != null) updateData['name'] = dto.name;
      if (dto.area != null) updateData['area'] = dto.area;

      if (updateData.isNotEmpty) {
        await db.update(
          table: 'courses',
          updateData: updateData,
          where: {"course_id": id},
        );
      }

      if (dto.removeCoursesModules != null &&
          dto.removeCoursesModules!.isNotEmpty) {
        final idsToRemove = dto.removeCoursesModules!
            .map((e) => "'${e.trim()}'")
            .join(',');

        await db.query(
          "UPDATE courses_modules SET sequence_course_module_id = NULL WHERE sequence_course_module_id IN ($idsToRemove)",
        );

        await db.query(
          "DELETE FROM courses_modules WHERE courses_modules_id IN ($idsToRemove)",
        );
      }

      if (dto.addCoursesModules != null && dto.addCoursesModules!.isNotEmpty) {
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

        final newModulesToInsert = <String>[];

        for (var item in dto.addCoursesModules!) {
          final modKey = item.moduleId.trim().toLowerCase();
          if (!moduleToRelationMap.containsKey(modKey)) {
            newModulesToInsert.add(item.moduleId);
            moduleToRelationMap[modKey] = uuid.v4();
          }
        }

        if (newModulesToInsert.isNotEmpty) {
          final insertValues = <String>[];
          final insertParams = <dynamic>[];

          for (final modId in newModulesToInsert) {
            insertValues.add("(?, ?, ?, ?)");
            insertParams.addAll([
              moduleToRelationMap[modId.trim().toLowerCase()],
              id,
              modId,
              null,
            ]);
          }

          final insertSql =
              "INSERT INTO courses_modules (courses_modules_id, course_id, module_id, sequence_course_module_id) VALUES ${insertValues.join(',')}";
          await db.query(insertSql, whereValues: insertParams, isStmt: true);
        }

        final caseStatements = <String>[];
        final caseParams = <dynamic>[];
        final whereIds = <String>[];

        for (final item in dto.addCoursesModules!) {
          final currentUuid =
              moduleToRelationMap[item.moduleId.trim().toLowerCase()];

          if (currentUuid != null) {
            String? parentUuid;
            if (item.sequenceModuleId != null) {
              parentUuid =
                  moduleToRelationMap[item.sequenceModuleId!
                      .trim()
                      .toLowerCase()];
            }

            caseStatements.add("WHEN ? THEN ?");
            caseParams.add(currentUuid);
            caseParams.add(parentUuid);

            whereIds.add("'$currentUuid'");
          }
        }

        if (caseStatements.isNotEmpty) {
          final updateSql =
              """
            UPDATE courses_modules 
            SET sequence_course_module_id = CASE courses_modules_id 
            ${caseStatements.join(' ')} 
            ELSE sequence_course_module_id 
            END
            WHERE courses_modules_id IN (${whereIds.join(',')})
          """;

          await db.query(updateSql, whereValues: caseParams, isStmt: true);
        }
      }

      await db.commit();
      return await getById(id);
    } catch (e, s) {
      if (db != null) await db.rollback();
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Error updating course",
          details: {"error": e.toString(), "stackTrace": s.toString()},
        ),
      );
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }

  @override
  Future<Result<OutputCourseDao>> delete(String id) async {
    MysqlUtils? db;

    try {
      final existingCourse = await getById(id);

      if (existingCourse.isFailure || existingCourse.data == null)
        return existingCourse;

      db = await MysqlConfiguration.getConnection();

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
    } finally {
      await MysqlConfiguration.closeConnection(db);
    }
  }
}
