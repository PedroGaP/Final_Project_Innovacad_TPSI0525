import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/summary/dao/output_summary_grid_dao.dart';
import 'package:innovacad_api/src/data/summary/dao/output_summary_grid_dao.dart';
import 'package:innovacad_api/src/data/summary/dto/save_summary_dto.dart';

abstract class ISummaryRepository {
  Future<Result<OutputSummaryGridDao>> getGridBySchedule(String scheduleId);
  Future<Result<bool>> saveSummary(SaveSummaryDto dto);
}
