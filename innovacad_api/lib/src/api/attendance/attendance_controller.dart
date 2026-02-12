import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/domain/attendance/service/i_attendance_service.dart';
import 'package:vaden/vaden.dart';

@Api(
  tag: "Attendances",
  description: "CRUD endpoint documentation for attendances",
)
@Controller('/attendances')
class AttendanceController {
  final IAttendanceService service;

  AttendanceController(this.service);

  @ApiOperation(
    summary: 'Get module attendance by its class module ID',
    description:
        'Retrieves attendances for a module by the class module unique identifier',
  )
  @ApiParam(name: 'id', description: 'The Class Module ID', required: true)
  @Get('/stats/<classModuleId>')
  Future<Response> getModuleAttendance(@Param() String classModuleId) async {
    final result = await service.getModuleAttendance(classModuleId);

    return resultToResponse(result);
  }
}
