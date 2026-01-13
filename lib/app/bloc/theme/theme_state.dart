import 'package:flutter/material.dart';

class ThemeState {
  const ThemeState({required this.themeMode, required this.dynamicColorEnabled, this.colorScheme});

  final ThemeMode themeMode;
  final bool dynamicColorEnabled;
  final ColorScheme? colorScheme;

  ThemeMode get currentTheme => themeMode;

  String get themeModeName {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  ThemeState copyWith({ThemeMode? themeMode, bool? dynamicColorEnabled, ColorScheme? colorScheme}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }
}
