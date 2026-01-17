import 'package:vaden/vaden.dart';

@DTO()
class VerifyEmailDto {
  final String callback;
  final String authToken;
  final String verifyToken;

  VerifyEmailDto({
    required this.callback,
    required this.authToken,
    required this.verifyToken,
  });
}
