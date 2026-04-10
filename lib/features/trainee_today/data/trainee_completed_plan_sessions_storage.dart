import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Plan sessions the trainee finished in this app, scoped to the **calendar week**
/// (Monday start, local). Fills gaps when the plan-detail API does not yet expose
/// completion on `sessions` / `planSessions` or per-exercise `status`.
class TraineeCompletedPlanSessionsStorage {
  TraineeCompletedPlanSessionsStorage(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String planId) =>
      'trainee_plan_done_sess_v1_${planId.trim()}';

  static DateTime _mondayOfWeekContaining(DateTime instant) {
    final day = DateTime(instant.year, instant.month, instant.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static String _weekKey(DateTime monday) =>
      '${monday.year.toString().padLeft(4, '0')}-'
      '${monday.month.toString().padLeft(2, '0')}-'
      '${monday.day.toString().padLeft(2, '0')}';

  static String get currentWeekKey =>
      _weekKey(_mondayOfWeekContaining(DateTime.now()));

  /// Resolved `planSessionId` values completed on this device this week.
  Future<Set<String>> completedPlanSessionIdsThisWeek(String planId) async =>
      readCompletedPlanSessionIdsThisWeekSync(planId);

  /// Same as [completedPlanSessionIdsThisWeek] for synchronous UI refresh (e.g. when
  /// returning from the runner after [pushReplacement] so `.then` on [Navigator.push] may not run).
  Set<String> readCompletedPlanSessionIdsThisWeekSync(String planId) {
    final wk = currentWeekKey;
    final raw = _prefs.getString(_key(planId));
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['weekKey']?.toString() != wk) return {};
      final list = map['sessions'];
      if (list is! List) return {};
      return list.map((e) => e.toString()).where((s) => s.isNotEmpty).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markPlanSessionCompletedThisWeek({
    required String planId,
    required String planSessionId,
  }) async {
    final sid = planSessionId.trim();
    if (planId.trim().isEmpty || sid.isEmpty) return;

    final wk = currentWeekKey;
    final key = _key(planId);
    Map<String, dynamic> map;
    final raw = _prefs.getString(key);
    if (raw != null && raw.isNotEmpty) {
      try {
        map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        map = <String, dynamic>{};
      }
      if (map['weekKey']?.toString() != wk) {
        map = {'weekKey': wk, 'sessions': <String>[]};
      }
    } else {
      map = {'weekKey': wk, 'sessions': <String>[]};
    }

    final sessions = (map['sessions'] as List?)
            ?.map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList() ??
        <String>[];
    if (!sessions.contains(sid)) sessions.add(sid);
    map['weekKey'] = wk;
    map['sessions'] = sessions;
    await _prefs.setString(key, jsonEncode(map));
  }
}
