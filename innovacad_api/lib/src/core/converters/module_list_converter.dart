import 'package:json_annotation/json_annotation.dart';
import 'package:innovacad_api/src/data/data.dart';

class ModuleListConverter
    implements JsonConverter<List<OutputClassModuleDao>, Object?> {
  const ModuleListConverter();

  @override
  List<OutputClassModuleDao> fromJson(Object? json) {
    if (json == null) return [];

    if (json is List<OutputClassModuleDao>) return json;

    if (json is List) {
      return json.map((e) {
        if (e is OutputClassModuleDao) return e;

        if (e is Map<String, dynamic>) return OutputClassModuleDao.fromJson(e);

        if (e is Map)
          return OutputClassModuleDao.fromJson(Map<String, dynamic>.from(e));

        throw ArgumentError(
          'Expected Map or OutputClassModuleDao, got ${e.runtimeType}',
        );
      }).toList();
    }

    return [];
  }

  @override
  Object? toJson(List<OutputClassModuleDao> object) =>
      object.map((e) => e.toJson()).toList();
}

const moduleListConverter = const ModuleListConverter();
