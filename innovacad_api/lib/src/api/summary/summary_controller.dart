import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/data/summary/dto/save_summary_dto.dart';
import 'package:innovacad_api/src/data/user/service/user_details_service_impl.dart';
import 'package:innovacad_api/src/domain/summary/service/i_summary_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: "Summaries", description: "Manage class summaries and attendances")
@Controller("/summaries")
class SummaryController {
  final ISummaryService _service;

  SummaryController(this._service);

  @ApiOperation(
    summary: 'Get Summary Grid',
    description:
        'Returns the summary details and student list with attendance checkboxes',
  )
  @Get('/schedule/<scheduleId>')
  Future<Response> getGrid(
    @Context() ExtendedUserDetails user,
    @Param("scheduleId") String scheduleId,
  ) async {
    return resultToResponse(await _service.getGrid(scheduleId, user));
  }

  @ApiOperation(
    summary: 'Save Summary',
    description: 'Creates or updates a summary and attendances',
  )
  @Post('/')
  Future<Response> save(
    @Body() SaveSummaryDto dto,
    @Context() ExtendedUserDetails user,
  ) async {
    return resultToResponse(await _service.save(dto, user));
  }
}
