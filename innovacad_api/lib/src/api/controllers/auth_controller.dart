import 'dart:convert';
import 'dart:io';

import 'package:better_auth_client/better_auth_client.dart';
import 'package:dio/dio.dart';
import 'package:vaden/vaden.dart' as v;

@v.Api(tag: 'Sign', description: 'AJDFDFJK')
@v.Controller('/sign')
class SignController {
  final Dio dio;

  SignController(this.dio);

  @v.Post('/signin')
  Future<v.Response> login() async {
    try {
      Response res = await dio.post(
        'http://localhost:10000/api/auth/sign-in/email',
        data: {'email': 'beatrizr@trainees.innovacad.pt', 'password': '1234'},
      );

      if (res.statusCode != HttpStatus.ok) {
        return v.Response.badRequest(body: jsonEncode({"erro": res.data}));
      }

      return v.Response.ok(jsonEncode(res.data));
    } catch (e, s) {
      print(e);
      print(s);
    }

    return v.Response.ok(jsonEncode("empty"));
  }
}
