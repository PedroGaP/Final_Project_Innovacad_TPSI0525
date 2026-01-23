import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:vaden/vaden.dart';

@Component()
enum ClassStatusEnum {
  @annotation.JsonValue('ongoing')
  ongoing,

  @annotation.JsonValue('starting')
  starting,

  @annotation.JsonValue('finished')
  finished,
}
