import 'package:innovacad_api/src/domain/domain.dart';
import 'package:vaden/vaden.dart';

@Controller('/user')
class UserController {
  final IUserService _service;

  UserController(this._service);
}
