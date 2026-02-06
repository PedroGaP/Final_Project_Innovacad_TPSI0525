import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/class_module/dto/link/link_class_module_dto.dart';
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

      // 1. Buscar todas as Turmas
      final query = """
        SELECT c.*, co.identifier AS course_identifier
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

      // 2. Preparar IDs para buscar módulos (Normalização não é estritamente necessária aqui no SQL, mas ajuda)
      final classIdsString = classesList
          .map((c) => "'${c['class_id'].toString()}'")
          .join(',');

      // 3. Buscar Módulos com Informação do Formador
      // NOTA: Usamos LEFT JOIN para trainers e users para não perder módulos sem formador
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

      final modulesResult = await db.query(modulesQuery, debug: true);

      // 4. Agrupar módulos por class_id (CORREÇÃO DE NORMALIZAÇÃO AQUI)
      final Map<String, List<Map<String, dynamic>>> modulesByClassId = {};

      for (final row in modulesResult.rowsAssoc) {
        final data = row.assoc();
        // Normaliza para lowercase para garantir que a chave bate certo
        final cId = data['class_id'].toString().trim().toLowerCase();

        if (!modulesByClassId.containsKey(cId)) {
          modulesByClassId[cId] = [];
        }

        // Tratamento de nulos para evitar erros de cast no DAO
        final moduleData = Map<String, dynamic>.from(data);
        if (moduleData['sequence_class_module_id'] == null)
          moduleData['sequence_class_module_id'] = null;
        if (moduleData['trainer_id'] == null) moduleData['trainer_id'] = null;
        if (moduleData['trainer_name'] == null)
          moduleData['trainer_name'] = null;

        // Remover class_id do objeto filho para limpar, se quiseres
        // moduleData.remove('class_id');

        modulesByClassId[cId]!.add(moduleData);
      }

      // 5. Anexar módulos às turmas
      final List<OutputClassDao> outputList = classesList.map((classData) {
        // Normaliza a chave aqui também
        final classId = classData['class_id'].toString().trim().toLowerCase();

        final Map<String, dynamic> fullData = Map.from(classData);

        // Busca a lista ou retorna vazia
        fullData['modules'] = modulesByClassId[classId] ?? [];

        return OutputClassDao.fromJson(fullData);
      }).toList();

      print(classesList);

      return Result.success(outputList);
    } catch (e, s) {
      print("[GetAll Class Error] $e"); // Log para ajudar a debuggar
      return Result.failure(
        AppError(
          AppErrorType.internal,
          "Something went wrong while fetching the classes...",
          details: {"error": e.toString(), "stacktrace": s.toString()},
        ),
      );
    } finally {
      // await db?.close();
    }
  }

  @override
  Future<Result<OutputClassDao>> getById(String id) async {
    MysqlUtils? db;

    try {
      db = await MysqlConfiguration.connect();

      // 1. Get Class Info
      final query = """
        SELECT c.*, co.identifier AS course_identifier
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

      // 2. Get Modules for this specific class
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
        // Null safety
        if (m['sequence_class_module_id'] == null)
          m['sequence_class_module_id'] = null;
        if (m['trainer_id'] == null) m['trainer_id'] = null;
        if (m['trainer_name'] == null) m['trainer_name'] = null;
        return m;
      }).toList();

      return Result.success(OutputClassDao.fromJson(fullData));
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

      if (dto.modules != null && dto.modules!.isNotEmpty) {
        for (final LinkClassModuleDto item in dto.modules!) {
          await db.insert(
            table: 'classes_modules',
            insertData: {
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

    print("Update Class DTO: ${dto.toJson()}");

    try {
      db = await MysqlConfiguration.connect();

      final existingClassResult = await getById(id);
      if (existingClassResult.isFailure || existingClassResult.data == null) {
        return existingClassResult;
      }

      await db.startTrans();

      // 1. Update Basic Class Info
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

      // 2. Remove Modules
      if (dto.removeClassesModulesIds != null &&
          dto.removeClassesModulesIds!.isNotEmpty) {
        for (final idToRemove in dto.removeClassesModulesIds!) {
          await db.delete(
            table: 'classes_modules',
            where: {"class_id": id, "courses_modules_id": idToRemove},
          );
        }
      }

      // 3. Add or Update Modules (FIX)
      if (dto.addModules != null && dto.addModules!.isNotEmpty) {
        // Vamos buscar a CHAVE PRIMÁRIA (classes_modules_id) para garantir que atualizamos a linha certa
        final currentModulesResult = await db.query(
          "SELECT classes_modules_id, courses_modules_id FROM classes_modules WHERE class_id = ?",
          whereValues: [id],
          isStmt: true,
        );

        // Mapa: CourseModuleID (vindo do DTO) -> ClassesModuleID (PK da BD)
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
            // UPDATE usando a PK
            final pkId = existingMap[courseModId];
            print(">> Updating Module PK: $pkId | Trainer: $trainerId");

            await db.query(
              "UPDATE classes_modules SET trainer_id = ? WHERE classes_modules_id = ?",
              whereValues: [trainerId, pkId], // trainerId null é aceite aqui
              isStmt: true,
            );
          } else {
            // INSERT
            print(">> Inserting Module: $courseModId | Trainer: $trainerId");
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
      await db?.rollback();
      print("Update Error: $e");
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
