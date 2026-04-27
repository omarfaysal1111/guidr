import 'dart:convert';

import 'package:guidr/core/storage/local_storage.dart';

/// Persists coach workout / nutrition builder content on-device (SharedPreferences).
/// Not synced to the server.
class PlanBuilderLocalStorage {
  PlanBuilderLocalStorage(this._prefs);

  final LocalStorage _prefs;

  static const _kWorkoutTemplates = 'plan_builder_v1_workout_templates';
  static const _kWorkoutDraft = 'plan_builder_v1_workout_draft';
  static const _kNutritionTemplates = 'plan_builder_v1_nutrition_templates';
  static const _kNutritionDraft = 'plan_builder_v1_nutrition_draft';
  static const int _maxTemplates = 30;

  // --- workout ---

  Future<void> saveWorkoutTemplate(
    Map<String, dynamic> snapshot, {
    String? displayName,
  }) async {
    final list = _readList(_kWorkoutTemplates);
    final title = displayName?.trim() ??
        (snapshot['planTitle'] as String?)?.trim() ??
        'Untitled template';
    list.insert(0, {
      'id': 'w_${DateTime.now().millisecondsSinceEpoch}',
      'name': title,
      'savedAt': DateTime.now().toIso8601String(),
      'data': snapshot,
    });
    while (list.length > _maxTemplates) {
      list.removeLast();
    }
    await _prefs.saveString(_kWorkoutTemplates, jsonEncode(list));
  }

  Future<void> saveWorkoutDraft(Map<String, dynamic> snapshot) async {
    await _prefs.saveString(_kWorkoutDraft, jsonEncode(snapshot));
  }

  String? get workoutDraftJson => _prefs.getString(_kWorkoutDraft);

  List<Map<String, dynamic>> listWorkoutTemplates() => _readList(_kWorkoutTemplates);

  Map<String, dynamic>? workoutTemplateDataById(String id) {
    for (final m in _readList(_kWorkoutTemplates)) {
      if (m['id'] == id) {
        final d = m['data'];
        if (d is Map) return Map<String, dynamic>.from(d);
      }
    }
    return null;
  }

  // --- nutrition ---

  Future<void> saveNutritionTemplate(
    Map<String, dynamic> snapshot, {
    String? displayName,
  }) async {
    final list = _readList(_kNutritionTemplates);
    final title = displayName?.trim() ??
        (snapshot['planName'] as String?)?.trim() ??
        'Untitled template';
    list.insert(0, {
      'id': 'n_${DateTime.now().millisecondsSinceEpoch}',
      'name': title,
      'savedAt': DateTime.now().toIso8601String(),
      'data': snapshot,
    });
    while (list.length > _maxTemplates) {
      list.removeLast();
    }
    await _prefs.saveString(_kNutritionTemplates, jsonEncode(list));
  }

  Future<void> saveNutritionDraft(Map<String, dynamic> snapshot) async {
    await _prefs.saveString(_kNutritionDraft, jsonEncode(snapshot));
  }

  String? get nutritionDraftJson => _prefs.getString(_kNutritionDraft);

  List<Map<String, dynamic>> listNutritionTemplates() =>
      _readList(_kNutritionTemplates);

  Map<String, dynamic>? nutritionTemplateDataById(String id) {
    for (final m in _readList(_kNutritionTemplates)) {
      if (m['id'] == id) {
        final d = m['data'];
        if (d is Map) return Map<String, dynamic>.from(d);
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _readList(String key) {
    final s = _prefs.getString(key);
    if (s == null || s.isEmpty) return [];
    try {
      final d = jsonDecode(s);
      if (d is! List) return [];
      return d.map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{};
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
