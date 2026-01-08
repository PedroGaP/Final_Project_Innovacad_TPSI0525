import 'package:vaden/vaden.dart';

@Component()
class Room {
  int room_id;
  String room_name;
  int capacity;

  Room({
    required this.room_id,
    required this.room_name,
    required this.capacity,
  });
}
