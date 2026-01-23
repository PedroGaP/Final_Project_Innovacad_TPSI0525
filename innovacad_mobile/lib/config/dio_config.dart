import 'package:dio/dio.dart';

class DioConfig {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.113:8080",
      validateStatus: (status) => true,
    ),
  );

  static Dio get dio => _dio;
}
