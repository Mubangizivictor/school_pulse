import 'package:shared_preferences/shared_preferences.dart';

/// Persists which Quick Access tiles a School Admin has chosen to show and
/// in what order, scoped per device (SharedPreferences has no per-school
/// namespace already established elsewhere in this codebase for this kind
/// of light UI preference, so a single key is fine - it only ever reflects
/// the signed-in user's own choice, never another tenant's data).
class QuickAccessPrefs {
  static const _key = 'admin_dashboard_quick_access_order_v1';

  /// Ids of every tile that can appear, in the app's default order. Core
  /// shortcuts (students/staff/attendance) are always kept visible even if
  /// a stale saved list predates them.
  static const List<String> allIds = [
    'students',
    'staff',
    'attendance',
    'classes',
    'exams',
    'finance',
    'transport',
    'library',
    'announcements',
    'communication',
    'reports',
    'calendar',
    'security',
    'institution_health',
    'data_management',
  ];

  static const List<String> coreIds = ['students', 'staff', 'attendance'];

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (saved == null || saved.isEmpty) return List.of(allIds);
    // Keep only ids that still exist, then append any new ids the app has
    // gained since this was saved so nothing new silently disappears.
    final known = saved.where(allIds.contains).toList();
    for (final id in allIds) {
      if (!known.contains(id)) known.add(id);
    }
    return known;
  }

  static Future<void> save(List<String> orderedVisibleIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, orderedVisibleIds);
  }
}
