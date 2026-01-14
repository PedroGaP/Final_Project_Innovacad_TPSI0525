import 'package:innovacad_api/src/domain/dtos/user/user_signup_dto.dart';
import 'package:vaden/vaden.dart';

class UserValidator extends LucidValidator<UserSignupDto> {
  UserValidator() {
    ruleFor((u) => u.password, key: 'password').notEmpty().minLength(8);

    ruleFor((u) => u.email, key: 'email').notEmpty().validEmail();
  }
}
