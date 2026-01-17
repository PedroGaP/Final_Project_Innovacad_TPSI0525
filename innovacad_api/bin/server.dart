import 'dart:io';
import 'package:innovacad_api/config/mysql/mysql_configuration.dart';
import 'package:innovacad_api/vaden_application.dart';

Future<void> main(List<String> args) async {
  final vaden = VadenApp();

  vaden.injector.add(MysqlConfiguration.new);
  await vaden.setup();
  final server = await vaden.run(args);

  print('--- InnovAcad API Server ---');
  print('Server is running on:');

  final interfaces = await NetworkInterface.list(
    includeLoopback: true,
    type: InternetAddressType.IPv4,
  );

  for (var interface in interfaces) {
    for (var addr in interface.addresses) {
      print('  > https://${addr.address}:${server.port}');
    }
  }

  print('----------------------------');
}
