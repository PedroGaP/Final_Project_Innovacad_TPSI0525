import 'package:vaden/vaden.dart';

@DTO()
class RoomUpdateDto {
  String room_name;
  int capacity;

  RoomUpdateDto({required this.room_name, required this.capacity});
}
