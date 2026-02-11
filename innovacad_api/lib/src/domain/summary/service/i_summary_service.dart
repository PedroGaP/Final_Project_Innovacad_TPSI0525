import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/data.dart';
import 'package:innovacad_api/src/data/summary/dao/output_summary_grid_dao.dart';
import 'package:innovacad_api/src/data/summary/dto/save_summary_dto.dart';

abstract class ISummaryService {
  Future<Result<OutputSummaryGridDao>> getGrid(
    String scheduleId,
    ExtendedUserDetails user,
  );
  Future<Result<bool>> save(SaveSummaryDto dto, ExtendedUserDetails user);
}
