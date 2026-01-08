import 'package:vaden/vaden.dart';

@DTO()
class RoomCreateDto {
  String room_name;
  int capacity;

  RoomCreateDto({required this.room_name, required this.capacity});
}
