import 'package:innovacad_api/src/core/core.dart';
import 'package:innovacad_api/src/domain/attendance/service/i_attendance_service.dart';
import 'package:vaden/vaden.dart';

@Controller('/attendance')
class AttendanceController {
  final IAttendanceService service;

  AttendanceController(this.service);

  @Get('/stats/<classModuleId>')
  Future<Response> getModuleAttendance(@Param() String classModuleId) async {
    final result = await service.getModuleAttendance(classModuleId);

    return resultToResponse(result);
  }
}
