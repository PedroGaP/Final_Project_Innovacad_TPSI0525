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

      final existingCourseResult = await getById(id);
      if (existingCourseResult.isFailure || existingCourseResult.data == null)
        return existingCourseResult;

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
        final idsToRemoveString = dto.removeCoursesModules!
            .map((e) => "'$e'")
            .join(',');

        await db.query(
          "UPDATE courses_modules SET sequence_course_module_id = NULL WHERE sequence_course_module_id IN ($idsToRemoveString)",
        );
        await db.query(
          "DELETE FROM courses_modules WHERE courses_modules_id IN ($idsToRemoveString)",
        );
      }

      // --- PASSO C: Bulk Insert & Link (VERSÃO ESTÁVEL) ---
      if (dto.addCoursesModules != null && dto.addCoursesModules!.isNotEmpty) {
        // 1. Carregar estado atual
        print("[DEBUG] Fetching current database state...");
        final currentRows = await db.query(
          "SELECT courses_modules_id, module_id FROM courses_modules WHERE course_id = ?",
          whereValues: [id],
          isStmt: true,
        );

        // MAPA: Normalizamos a chave (module_id) para lowercase para evitar erros de comparação
        final Map<String, String> moduleToRelationMap = {
          for (var row in currentRows.rowsAssoc)
            row.assoc()['module_id'].toString().trim().toLowerCase(): row
                .assoc()['courses_modules_id']
                .toString(),
        };

        // 2. Calcular quem precisa de ser inserido
        // Nota: Também normalizamos o ID do DTO para lowercase
        final explicitIds = dto.addCoursesModules!
            .map((e) => e.moduleId.trim().toLowerCase())
            .toSet();

        final implicitParents = dto.addCoursesModules!
            .map((e) => e.sequenceModuleId?.trim().toLowerCase())
            .where(
              (seqId) =>
                  seqId != null &&
                  !explicitIds.contains(seqId) &&
                  !moduleToRelationMap.containsKey(seqId),
            )
            .toSet();

        // Lista final de módulos NOVOS a inserir
        final List<String> modulesToInsert =
            [...implicitParents, ...explicitIds]
                .where(
                  (modId) =>
                      !moduleToRelationMap.containsKey(modId!) && modId != null,
                )
                .cast<String>()
                .toList();

        // ---------------------------------------------------------
        // OTIMIZAÇÃO 1: Bulk Insert (Mantemos, pois funciona bem)
        // ---------------------------------------------------------
        if (modulesToInsert.isNotEmpty) {
          final insertValues = <String>[];
          final insertParams = <dynamic>[];

          print("[DEBUG] Inserting ${modulesToInsert.length} new modules...");

          for (final modId in modulesToInsert) {
            final newRelationUuid = uuid.v4();

            // Atualizar mapa (chave lowercase)
            moduleToRelationMap[modId] = newRelationUuid;

            insertValues.add("(?, ?, ?, ?)");
            // O modId aqui já é o lowercase/trim da lista acima
            insertParams.addAll([newRelationUuid, id, modId, null]);
          }

          final insertSql =
              "INSERT INTO courses_modules (courses_modules_id, course_id, module_id, sequence_course_module_id) VALUES ${insertValues.join(',')}";

          await db.query(insertSql, whereValues: insertParams, isStmt: true);
        }

        print("[DEBUG] Updating sequences...");
        
        for (final item in dto.addCoursesModules!) {
          
          // 1. Encontrar o UUID do módulo que estamos a atualizar
          final modKey = item.moduleId.trim().toLowerCase();
          final currentUuid = moduleToRelationMap[modKey];

          if (currentUuid == null) {
            print("[DEBUG] ERRO: UUID não encontrado para o módulo ${item.moduleId}");
            continue;
          }

          // 2. Verificar se é para ligar a um Pai ou para Desligar (Null)
          if (item.sequenceModuleId != null) {
            // --- CASO A: Tem um Pai (Ligar) ---
            final seqKey = item.sequenceModuleId!.trim().toLowerCase();
            final parentUuid = moduleToRelationMap[seqKey];

            if (parentUuid != null) {
              await db.update(
                table: 'courses_modules',
                updateData: {"sequence_course_module_id": parentUuid},
                where: {"courses_modules_id": currentUuid},
              );
            } else {
              print("[DEBUG] AVISO: Pai ${item.sequenceModuleId} não encontrado no mapa.");
            }
          } else {
            // --- CASO B: É Null (Remover Sequência / "None") ---
            // AQUI ESTÁ A CORREÇÃO: Forçamos o update para NULL explicitamente
            
            await db.update(
              table: 'courses_modules',
              updateData: {"sequence_course_module_id": null}, // <--- O Segredo
              where: {"courses_modules_id": currentUuid},
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
          "Error updating course batch",
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
