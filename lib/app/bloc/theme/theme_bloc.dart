import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.system, dynamicColorEnabled: false)) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ToggleDynamicColor>(_onToggleDynamicColor);
    add(LoadTheme());
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final dynamicColorEnabled = prefs.getBool('dynamicColorEnabled') ?? false;

    final themeMode = ThemeMode.values[themeIndex];

    emit(ThemeState(themeMode: themeMode, dynamicColorEnabled: dynamicColorEnabled));
  }

  Future<void> _onChangeThemeMode(ChangeThemeMode event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', event.themeMode.index);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onToggleDynamicColor(ToggleDynamicColor event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dynamicColorEnabled', event.enabled);
    emit(state.copyWith(dynamicColorEnabled: event.enabled));
  }
}
