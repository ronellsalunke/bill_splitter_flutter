import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  const ThemeState({
    required this.themeMode,
    required this.dynamicColorEnabled,
  });

  final ThemeMode themeMode;
  final bool dynamicColorEnabled;

  ThemeState copyWith({ThemeMode? themeMode, bool? dynamicColorEnabled}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
    );
  }

  @override
  List<Object> get props => [themeMode, dynamicColorEnabled];
}
