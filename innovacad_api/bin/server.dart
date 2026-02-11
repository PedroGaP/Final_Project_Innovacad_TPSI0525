import 'dart:io';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/src/core/middleware/loom_logger.dart';
import 'package:innovacad_api/vaden_application.dart';

SecurityContext getSecurityContext(String password) {
  final chain = Platform.script
      .resolve('certificates/server_chain.pem')
      .toFilePath();
  final key = Platform.script
      .resolve('certificates/server_key.pem')
      .toFilePath();

  return SecurityContext()
    ..useCertificateChain(chain)
    ..usePrivateKey(key, password: password);
}

void main(List<String> args) async {
  final vaden = VadenApp();

  vaden.injector.add(MysqlConfiguration.new);

  await vaden.setup();
  final server = await vaden.run(args);

  print(
    '${LoomColors.title} Server is running on port ${server.address.address}:${server.port}',
  );
}
