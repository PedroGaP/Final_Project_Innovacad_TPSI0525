import 'package:vaden/vaden.dart';

@DTO()
class UserLinkAccountDto {
  final String provider;
  final String callback;
  final String token;

  UserLinkAccountDto({
    required this.provider,
    required this.callback,
    required this.token,
  });
}
