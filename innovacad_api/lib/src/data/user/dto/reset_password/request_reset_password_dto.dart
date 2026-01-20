import 'package:vaden/vaden.dart';

@DTO()
class RequestResetPasswordDto {
  final String email;
  final String redirectTo;

  RequestResetPasswordDto({required this.email, required this.redirectTo});
}
