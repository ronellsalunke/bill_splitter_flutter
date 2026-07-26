import 'package:equatable/equatable.dart';

enum AppThemeMode { system, light, dark }

class ThemeState extends Equatable {
  const ThemeState({required this.themeMode, required this.dynamicColorEnabled});

  final AppThemeMode themeMode;
  final bool dynamicColorEnabled;

  ThemeState copyWith({AppThemeMode? themeMode, bool? dynamicColorEnabled}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
    );
  }

  @override
  List<Object> get props => [themeMode, dynamicColorEnabled];
}
