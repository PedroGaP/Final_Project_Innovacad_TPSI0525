import 'package:json_annotation/json_annotation.dart';

enum ClassStatusEnum {
  @JsonValue('ongoing')
  ongoing,

  @JsonValue('starting')
  starting,

  @JsonValue('finished')
  finished,
}
