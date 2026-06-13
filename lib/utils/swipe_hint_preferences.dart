import 'package:shared_preferences/shared_preferences.dart';

class SwipeHintPreferences {
  SwipeHintPreferences(this._prefs);

  static const homeBillActionsHintShownKey = 'homeBillActionsHintShown';
  static const homeBillActionsHintPendingKey = 'homeBillActionsHintPending';

  final SharedPreferences _prefs;

  bool get isHomeBillActionsHintPending => _prefs.getBool(homeBillActionsHintPendingKey) ?? false;

  Future<void> scheduleHomeBillActionsHint() async {
    if (_prefs.getBool(homeBillActionsHintShownKey) ?? false) {
      return;
    }

    await _prefs.setBool(homeBillActionsHintPendingKey, true);
  }

  Future<void> markHomeBillActionsHintShown() async {
    await _prefs.setBool(homeBillActionsHintShownKey, true);
    await _prefs.remove(homeBillActionsHintPendingKey);
  }
}
