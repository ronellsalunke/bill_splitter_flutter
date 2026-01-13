import 'package:flutter/material.dart';

abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ChangeThemeMode extends ThemeEvent {
  ChangeThemeMode(this.themeMode);

  final ThemeMode themeMode;
}

class ToggleDynamicColor extends ThemeEvent {
  ToggleDynamicColor(this.enabled);

  final bool enabled;
}
