import 'dart:async';

import 'package:vaden/vaden.dart';

@Controller('/resource')
class ResourceController {
  final ResourceService resource;

  const ResourceController(this.resource);

  @Mount('/public')
  FutureOr<Response> getResources(Request request) {
    return resource.call(request);
  }
}
