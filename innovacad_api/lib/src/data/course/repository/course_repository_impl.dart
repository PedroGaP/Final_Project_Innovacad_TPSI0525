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

        print('DEBUG: Curso $cId tem ${modulesList.length} módulos');

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

      print(
        'DEBUG getById: Curso encontrado com ${modulesList.length} módulos.',
      );

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

        for (final item in dto.addModulesIds!) {
          final String newRelationUuid = uuid.v4();

          await db.insert(
            table: 'courses_modules',
            insertData: {
              "courses_modules_id": newRelationUuid,
              "course_id": newCourseId,
              "module_id": item.moduleId,
              "sequence_course_module_id": null,
            },
          );

          moduleToRelationMap[item.moduleId] = newRelationUuid;
        }

        for (final item in dto.addModulesIds!) {
          if (item.sequenceModuleId != null) {
            final String currentRelationUuid =
                moduleToRelationMap[item.moduleId]!;

            final String? parentRelationUuid =
                moduleToRelationMap[item.sequenceModuleId];

            if (parentRelationUuid != null) {
              await db.update(
                table: 'courses_modules',
                updateData: {"sequence_course_module_id": parentRelationUuid},
                where: {"courses_modules_id": currentRelationUuid},
              );
            } else {
              print(
                "Aviso: Módulo ${item.moduleId} depende de ${item.sequenceModuleId} que não foi incluído.",
              );
            }
          }
        }
      }

      await db.commit();

      return await getById(newCourseId);
    } catch (e, s) {
      await db?.rollback();
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

      final existingCourseResult = await getById(id);
      if (existingCourseResult.isFailure || existingCourseResult.data == null) {
        return existingCourseResult;
      }

      await db.startTrans();

      final updateData = <String, dynamic>{};
      if (dto.identifier != null &&
          dto.identifier != existingCourseResult.data!.identifier)
        updateData['identifier'] = dto.identifier;
      if (dto.name != null && dto.name != existingCourseResult.data!.name)
        updateData['name'] = dto.name;

      if (updateData.isNotEmpty) {
        await db.update(
          table: 'courses',
          updateData: updateData,
          where: {"course_id": id},
        );
      }

      if (dto.removeCoursesModules != null &&
          dto.removeCoursesModules!.isNotEmpty) {
        for (final idToRemove in dto.removeCoursesModules!) {
          await db.update(
            table: 'courses_modules',
            updateData: {'sequence_course_module_id': null},
            where: {'sequence_course_module_id': idToRemove},
          );

          await db.delete(
            table: 'courses_modules',
            where: {"courses_modules_id": idToRemove},
          );
        }
      }

      if (dto.addCoursesModules != null && dto.addCoursesModules!.isNotEmpty) {
        final currentRows = await db.query(
          "SELECT courses_modules_id, module_id FROM courses_modules WHERE course_id = ?",
          whereValues: [id],
          isStmt: true,
        );

        final Map<String, String> moduleToRelationMap = {
          for (var row in currentRows.rowsAssoc)
            row.assoc()['module_id'].toString(): row
                .assoc()['courses_modules_id']
                .toString(),
        };

        final explicitIds = dto.addCoursesModules!
            .map((e) => e.moduleId)
            .toSet();

        final implicitParents = dto.addCoursesModules!
            .map((e) => e.sequenceModuleId)
            .where(
              (seqId) =>
                  seqId != null &&
                  !explicitIds.contains(seqId) &&
                  !moduleToRelationMap.containsKey(seqId),
            )
            .toSet();

        Future<void> insertModule(String moduleId) async {
          if (!moduleToRelationMap.containsKey(moduleId)) {
            final newRelationUuid = uuid.v4();
            await db!.insert(
              table: 'courses_modules',
              insertData: {
                "courses_modules_id": newRelationUuid,
                "course_id": id,
                "module_id": moduleId,
                "sequence_course_module_id": null,
              },
            );
            moduleToRelationMap[moduleId] = newRelationUuid;
          }
        }

        for (final parentId in implicitParents) {
          await insertModule(parentId!);
        }

        for (final item in dto.addCoursesModules!) {
          await insertModule(item.moduleId);
        }

        for (final item in dto.addCoursesModules!) {
          final currentRelationUuid = moduleToRelationMap[item.moduleId]!;
          String? parentRelationUuid;

          if (item.sequenceModuleId != null) {
            parentRelationUuid = moduleToRelationMap[item.sequenceModuleId];

            if (parentRelationUuid == null) {
              print(
                "AVISO: Dependência ${item.sequenceModuleId} não encontrada.",
              );
            }
          }

          await db.update(
            table: 'courses_modules',
            updateData: {"sequence_course_module_id": parentRelationUuid},
            where: {"courses_modules_id": currentRelationUuid},
          );
        }
      }

      await db.commit();
      return await getById(id);
    } catch (e, s) {
      await db?.rollback();
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
