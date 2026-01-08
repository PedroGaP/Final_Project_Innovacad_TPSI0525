import 'package:vaden/vaden.dart';

@DTO()
class ModuleUpdateDto {
  String name;
  int duration;

  ModuleUpdateDto({required this.name, required this.duration});
}
