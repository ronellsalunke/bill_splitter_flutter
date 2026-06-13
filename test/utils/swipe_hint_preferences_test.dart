import 'package:bs_flutter/utils/swipe_hint_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SwipeHintPreferences', () {
    test('schedules the home bill actions hint when it has not been shown', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final hintPrefs = SwipeHintPreferences(prefs);

      await hintPrefs.scheduleHomeBillActionsHint();

      expect(hintPrefs.isHomeBillActionsHintPending, isTrue);
      expect(prefs.getBool(SwipeHintPreferences.homeBillActionsHintShownKey), isNot(isTrue));
    });

    test('does not schedule the home bill actions hint after it is shown', () async {
      SharedPreferences.setMockInitialValues({SwipeHintPreferences.homeBillActionsHintShownKey: true});
      final prefs = await SharedPreferences.getInstance();
      final hintPrefs = SwipeHintPreferences(prefs);

      await hintPrefs.scheduleHomeBillActionsHint();

      expect(hintPrefs.isHomeBillActionsHintPending, isFalse);
    });

    test('marks the home bill actions hint as shown and clears the pending flag', () async {
      SharedPreferences.setMockInitialValues({SwipeHintPreferences.homeBillActionsHintPendingKey: true});
      final prefs = await SharedPreferences.getInstance();
      final hintPrefs = SwipeHintPreferences(prefs);

      await hintPrefs.markHomeBillActionsHintShown();

      expect(prefs.getBool(SwipeHintPreferences.homeBillActionsHintShownKey), isTrue);
      expect(hintPrefs.isHomeBillActionsHintPending, isFalse);
    });
  });
}
