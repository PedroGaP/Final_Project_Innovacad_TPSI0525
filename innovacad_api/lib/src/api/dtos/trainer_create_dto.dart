import 'package:vaden/vaden.dart';

@DTO()
class TrainerCreateDto {
  String name;
  String expertise;

  TrainerCreateDto({required this.name, required this.expertise});
}
