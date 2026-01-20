import 'package:vaden/vaden.dart';

@DTO()
class ResetPasswordDto {
  final String token;
  final String newPassword;

  ResetPasswordDto({required this.token, required this.newPassword});
}
