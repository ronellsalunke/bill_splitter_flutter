import 'package:bs_flutter/app/bloc/theme/theme_cubit.dart';
import 'package:bs_flutter/app/bloc/theme/theme_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ThemeCubit> _createCubit(Map<String, Object> initialValues) async {
  SharedPreferences.setMockInitialValues(initialValues);
  return ThemeCubit(await SharedPreferences.getInstance());
}

void main() {
  test('loads persisted preferences synchronously', () async {
    final cubit = await _createCubit({'themeMode': AppThemeMode.dark.index, 'dynamicColorEnabled': true});

    expect(cubit.state, const ThemeState(themeMode: AppThemeMode.dark, dynamicColorEnabled: true));

    await cubit.close();
  });

  test('falls back to system theme for an invalid stored index', () async {
    final cubit = await _createCubit({'themeMode': AppThemeMode.values.length});

    expect(cubit.state.themeMode, AppThemeMode.system);

    await cubit.close();
  });

  test('cycles through theme modes and persists each selection', () async {
    final cubit = await _createCubit({});
    final emittedStates = <ThemeState>[];
    final subscription = cubit.stream.listen(emittedStates.add);

    await cubit.cycleThemeMode();
    expect(cubit.state.themeMode, AppThemeMode.light);

    await cubit.cycleThemeMode();
    expect(cubit.state.themeMode, AppThemeMode.dark);

    await cubit.cycleThemeMode();
    expect(cubit.state.themeMode, AppThemeMode.system);

    expect(emittedStates, [
      const ThemeState(themeMode: AppThemeMode.light, dynamicColorEnabled: false),
      const ThemeState(themeMode: AppThemeMode.dark, dynamicColorEnabled: false),
      const ThemeState(themeMode: AppThemeMode.system, dynamicColorEnabled: false),
    ]);
    expect((await SharedPreferences.getInstance()).getInt('themeMode'), AppThemeMode.system.index);

    await subscription.cancel();
    await cubit.close();
  });

  test('updates and persists the dynamic color preference', () async {
    final cubit = await _createCubit({});

    await cubit.setDynamicColorEnabled(true);

    expect(cubit.state.dynamicColorEnabled, isTrue);
    expect((await SharedPreferences.getInstance()).getBool('dynamicColorEnabled'), isTrue);

    await cubit.close();
  });
}
