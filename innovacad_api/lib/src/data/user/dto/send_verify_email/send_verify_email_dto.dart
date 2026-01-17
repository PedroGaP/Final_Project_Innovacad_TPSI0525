import 'package:vaden/vaden.dart';

@DTO()
class SendVerifyEmailDto {
  final String email;
  final String token;

  SendVerifyEmailDto({required this.email, required this.token});
}
