import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _themeModeKey = 'themeMode';
  static const _dynamicColorEnabledKey = 'dynamicColorEnabled';

  ThemeCubit(this._prefs) : super(_initialState(_prefs));

  final SharedPreferences _prefs;

  Future<void> cycleThemeMode() {
    final nextMode = switch (state.themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };

    return setThemeMode(nextMode);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (themeMode == state.themeMode) return;

    emit(state.copyWith(themeMode: themeMode));
    await _prefs.setInt(_themeModeKey, themeMode.index);
  }

  Future<void> setDynamicColorEnabled(bool enabled) async {
    if (enabled == state.dynamicColorEnabled) return;

    emit(state.copyWith(dynamicColorEnabled: enabled));
    await _prefs.setBool(_dynamicColorEnabledKey, enabled);
  }

  static ThemeState _initialState(SharedPreferences prefs) {
    final storedThemeIndex = prefs.getInt(_themeModeKey);
    final themeMode = storedThemeIndex != null && storedThemeIndex >= 0 && storedThemeIndex < ThemeMode.values.length
        ? ThemeMode.values[storedThemeIndex]
        : ThemeMode.system;

    return ThemeState(themeMode: themeMode, dynamicColorEnabled: prefs.getBool(_dynamicColorEnabledKey) ?? false);
  }
}
