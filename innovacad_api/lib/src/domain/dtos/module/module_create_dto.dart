import 'package:vaden/vaden.dart';

@DTO()
class ModuleCreateDto {
  String name;
  int duration;

  ModuleCreateDto({required this.name, required this.duration});
}
