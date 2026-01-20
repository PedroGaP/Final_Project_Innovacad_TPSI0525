import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/domain/course_module/repository/i_course_module_repository.dart';
import 'package:mysql_utils/mysql_utils.dart';
import 'package:vaden/vaden.dart';

@Repository()
class CourseModuleRepositoryImpl implements ICourseModuleRepository {
  final String table = "courses_modules";

  @override
  Future<Result<List<OutputCourseModuleDao>>> getAll() async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final results = await db.getAll(table: table);
      
      final items = results.map((row) {
         return OutputCourseModuleDao(
            coursesModulesId: row["id"].toString(), // Assuming 'id' is PK
            courseId: row["course_id"].toString(),
            moduleId: row["module_id"].toString(), 
            sequenceCourseModuleId: row["sequence_course_module_id"]?.toString()
         );
      }).toList();
      
      return Result.success(items);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputCourseModuleDao>> getById(String id) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      final result = await db.getOne(table: table, where: {"id": id});
      
      if (result.isEmpty) {
         return Result.failure(AppError(AppErrorType.notFound, "CourseModule association not found"));
      }

      final dao = OutputCourseModuleDao(
         coursesModulesId: result["id"].toString(),
         courseId: result["course_id"].toString(),
         moduleId: result["module_id"].toString(),
         sequenceCourseModuleId: result["sequence_course_module_id"]?.toString()
      );
      
      return Result.success(dao);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputCourseModuleDao>> create(CreateCourseModuleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      await db.insert(
         table: table,
         insertData: {
            "course_id": dto.courseId,
            "module_id": dto.moduleId,
            "sequence_course_module_id": dto.sequenceCourseModuleId
         }
      );
      
      // Retrieval strategy: Assuming (course_id, module_id) is unique enough for now? 
      // Risk: duplicates allowed? A join table usually implies uniqueness but old entity didn't specify.
      // We will query by course_id and module_id. If multiple, we might get one. 
      // Ideally use insert ID.
      
      final created = await db.getOne(table: table, where: {"course_id": dto.courseId, "module_id": dto.moduleId}); 
       
      if (created.isEmpty) {
          return Result.failure(AppError(AppErrorType.internal, "Created association could not be retrieved"));
      }
      
      return Result.success(OutputCourseModuleDao(
         coursesModulesId: created["id"].toString(), 
         courseId: created["course_id"].toString(),
         moduleId: created["module_id"].toString(),
         sequenceCourseModuleId: created["sequence_course_module_id"]?.toString()
      ));
      
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputCourseModuleDao>> update(UpdateCourseModuleDto dto) async {
    MysqlUtils? db;
    try {
      db = await MysqlConfiguration.connect();
      
      final updateData = <String, dynamic>{};
      if (dto.courseId != null) updateData["course_id"] = dto.courseId;
      if (dto.moduleId != null) updateData["module_id"] = dto.moduleId;
      if (dto.sequenceCourseModuleId != null) updateData["sequence_course_module_id"] = dto.sequenceCourseModuleId;
      
      if (updateData.isEmpty) {
          return getById(dto.coursesModulesId);
      }
      
      await db.update(
         table: table,
         updateData: updateData,
         where: {"id": dto.coursesModulesId}
      );
      
      return getById(dto.coursesModulesId);
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }

  @override
  Future<Result<OutputCourseModuleDao>> delete(DeleteCourseModuleDto dto) async {
    MysqlUtils? db;
    try {
      final existingRes = await getById(dto.coursesModulesId);
      if (existingRes.isFailure) return existingRes;
      
      db = await MysqlConfiguration.connect();
      await db.delete(table: table, where: {"id": dto.coursesModulesId});
      
      return existingRes;
    } catch (e) {
      return Result.failure(AppError(AppErrorType.internal, e.toString()));
    }
  }
}
