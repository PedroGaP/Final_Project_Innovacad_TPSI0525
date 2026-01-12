import 'package:dio/dio.dart';
import 'package:vaden/vaden.dart';

@Configuration()
class DioConfiguration {
  @Bean()
  Dio dioApoiaseConfig(ApplicationSettings settings) {
    return Dio(
      BaseOptions(
        validateStatus: (status) => true,
        //baseUrl: settings['env']['base_url'],
        headers: {},
      ),
    );
  }
}
