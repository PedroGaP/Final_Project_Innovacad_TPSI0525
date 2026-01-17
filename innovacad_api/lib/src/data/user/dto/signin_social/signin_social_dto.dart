import 'package:vaden/vaden.dart';

@DTO()
class SigninSocialDto {
  final String provider;
  final String callback;

  SigninSocialDto({required this.provider, required this.callback});
}
