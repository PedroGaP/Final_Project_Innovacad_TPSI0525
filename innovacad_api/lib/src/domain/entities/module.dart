import 'package:vaden/vaden.dart';

@Component()
class Module {
  String module_id;
  String name;
  int duration;

  Module({required this.module_id, required this.name, required this.duration});
}
