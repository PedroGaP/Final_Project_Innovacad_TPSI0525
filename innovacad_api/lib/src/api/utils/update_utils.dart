import 'package:innovacad_api/src/domain/types/patch_model_type.dart';

class UpdateUtils {
  static PatchModelType patchModel(
    Map<String, dynamic> model,
    Map<String, dynamic> dto,
  ) {
    final patchedModel = Map<String, dynamic>.of(model);
    final updatedFields = <String, dynamic>{};

    for (final entry in dto.entries) {
      final key = entry.key;
      final dtoValue = entry.value;

      if (!patchedModel.containsKey(key)) continue;

      final modelValue = patchedModel[key];

      if (dtoValue == null || modelValue == dtoValue) continue;

      if (_isDateKey(key)) {
        final parsedDate = _parseDate(dtoValue);

        if (parsedDate != null && parsedDate != modelValue) {
          updatedFields[key] = parsedDate;
          patchedModel[key] = parsedDate;
        }
      } else {
        updatedFields[key] = dtoValue;
        patchedModel[key] = dtoValue;
      }
    }

    for (final key in patchedModel.keys.toList()) {
      if (_isDateKey(key)) {
        final currentVal = patchedModel[key];

        if (currentVal is! DateTime) {
          final parsed = _parseDate(currentVal);

          if (parsed != null) patchedModel[key] = parsed;
        }
      }
    }

    return PatchModelType(
      patchedModel: patchedModel,
      updatedFields: updatedFields,
    );
  }

  static bool _isDateKey(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('date') || lowerKey.contains('timestamp');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    try {
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

      if (value is String) {
        final intVal = int.tryParse(value);
        if (intVal != null) return DateTime.fromMillisecondsSinceEpoch(intVal);

        return DateTime.tryParse(value);
      }
    } catch (e, s) {
      print('[ERROR]: $e\n[STACK]: $s');
    }

    return null;
  }
}
