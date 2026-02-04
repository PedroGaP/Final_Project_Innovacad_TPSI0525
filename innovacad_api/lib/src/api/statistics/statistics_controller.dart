import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/statistics/repository/statistics_repository.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'Statistics', description: 'Dashboard statistics endpoints')
@Controller('/statistics')
class StatisticsController {
  final StatisticsRepository _repository;

  StatisticsController(this._repository);

  @ApiOperation(
    summary: 'Get dashboard statistics',
    description:
        'Retrieves aggregated statistics for the dashboard including totals, courses by area, and top trainers',
  )
  @Get('/')
  Future<Response> getStatistics() async {
    final result = await _repository.getStatistics();

    return resultToResponse(result);
  }
}
