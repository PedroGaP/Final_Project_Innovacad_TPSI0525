import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/summary/dao/output_summary_grid_dao.dart';
import 'package:innovacad_api/src/data/summary/dto/save_summary_dto.dart';
import 'package:innovacad_api/src/domain/summary/repository/i_summary_repository.dart';
import 'package:innovacad_api/src/domain/summary/service/i_summary_service.dart';
import 'package:vaden/vaden.dart';

@Service()
class SummaryServiceImpl implements ISummaryService {
  final ISummaryRepository _repository;

  SummaryServiceImpl(this._repository);

  Future<Result<bool>> _validateAccess(
    String scheduleId,
    ExtendedUserDetails user, {
    bool checkTime = false,
  }) async {
    if (['admin', 'assistant'].contains(user.roles.first))
      return Result.success(true);

    return await MysqlConfiguration.executeWithConnection((db) async {
      final schedule = await db.getOne(
        table: 'schedules',
        where: {'schedule_id': scheduleId},
      );

      if (schedule.isEmpty)
        return Result.failure(
          AppError(AppErrorType.notFound, "Schedule not found"),
        );

      if (user.roles.first == 'trainer') {
        if (schedule['trainer_id'] != user.trainerId) {
          return Result.failure(
            AppError(
              AppErrorType.forbidden,
              "Only the assigned trainer can manage this summary.",
            ),
          );
        }
      }

      if (checkTime) {
        final startTimeStr = schedule['start_date_timestamp'];
        if (startTimeStr != null) {
          final start = DateTime.parse(startTimeStr.toString());
          if (DateTime.now().isBefore(start)) {
            return Result.failure(
              AppError(
                AppErrorType.badRequest,
                "Cannot create summary before class start time.",
              ),
            );
          }
        }
      }

      return Result.success(true);
    });
  }

  @override
  Future<Result<OutputSummaryGridDao>> getGrid(
    String scheduleId,
    ExtendedUserDetails user,
  ) async {
    final access = await _validateAccess(scheduleId, user, checkTime: false);
    if (access.isFailure) return Result.failure(access.error!);

    return await _repository.getGridBySchedule(scheduleId);
  }

  @override
  Future<Result<bool>> save(
    SaveSummaryDto dto,
    ExtendedUserDetails user,
  ) async {
    final access = await _validateAccess(dto.scheduleId, user, checkTime: true);
    if (access.isFailure) return Result.failure(access.error!);

    return await _repository.saveSummary(dto);
  }
}
