import 'package:flutter/material.dart';

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.actionBackground,
    required this.onActionBackground,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  final Color actionBackground;
  final Color onActionBackground;
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  @override
  AppThemeColors copyWith({
    Color? actionBackground,
    Color? onActionBackground,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
  }) {
    return AppThemeColors(
      actionBackground: actionBackground ?? this.actionBackground,
      onActionBackground: onActionBackground ?? this.onActionBackground,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      actionBackground: Color.lerp(actionBackground, other.actionBackground, t) ?? actionBackground,
      onActionBackground: Color.lerp(onActionBackground, other.onActionBackground, t) ?? onActionBackground,
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      successContainer: Color.lerp(successContainer, other.successContainer, t) ?? successContainer,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t) ?? onSuccessContainer,
    );
  }
}

class AppTheme {
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceDim = Color(0xFFF2F2F2);
  static const Color _lightOnSurfaceVariant = Color(0xFF5A5A5A);
  static const Color _darkSurface = Color(0xFF121212);
  static const Color _darkSurfaceDim = Color(0xFF1E1E1E);
  static const Color _darkOnSurfaceVariant = Color(0xFFB3B3B3);
  static const Color _lightError = Color(0xFFB3261E);
  static const Color _lightOnError = Colors.white;
  static const Color _lightErrorContainer = Color(0xFFF9DEDC);
  static const Color _lightOnErrorContainer = Color(0xFF410E0B);
  static const Color _darkError = Color(0xFFF2B8B5);
  static const Color _darkOnError = Color(0xFF601410);
  static const Color _darkErrorContainer = Color(0xFF8C1D18);
  static const Color _darkOnErrorContainer = Color(0xFFF9DEDC);
  static const Color _lightSuccess = Color(0xFF1F7A3D);
  static const Color _lightOnSuccess = Colors.white;
  static const Color _lightSuccessContainer = Color(0xFFDDF4E4);
  static const Color _lightOnSuccessContainer = Color(0xFF0F2917);
  static const Color _darkSuccess = Color(0xFFA4D6A8);
  static const Color _darkOnSuccess = Color(0xFF073818);
  static const Color _darkSuccessContainer = Color(0xFF1E512C);
  static const Color _darkOnSuccessContainer = Color(0xFFC0F2C3);

  static ColorScheme monochromeColorScheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    ).copyWith(
      primary: isLight ? Colors.black : Colors.white,
      onPrimary: isLight ? Colors.white : Colors.black,
      primaryContainer: isLight ? _lightSurfaceDim : _darkSurfaceDim,
      onPrimaryContainer: isLight ? Colors.black : Colors.white,
      secondary: isLight ? Colors.black : Colors.white,
      onSecondary: isLight ? Colors.white : Colors.black,
      secondaryContainer: isLight ? _lightSurfaceDim : _darkSurfaceDim,
      onSecondaryContainer: isLight ? Colors.black : Colors.white,
      tertiary: isLight ? Colors.black : Colors.white,
      onTertiary: isLight ? Colors.white : Colors.black,
      tertiaryContainer: isLight ? _lightSurfaceDim : _darkSurfaceDim,
      onTertiaryContainer: isLight ? Colors.black : Colors.white,
      error: isLight ? _lightError : _darkError,
      onError: isLight ? _lightOnError : _darkOnError,
      errorContainer: isLight ? _lightErrorContainer : _darkErrorContainer,
      onErrorContainer: isLight ? _lightOnErrorContainer : _darkOnErrorContainer,
      surface: isLight ? _lightSurface : _darkSurface,
      onSurface: isLight ? Colors.black : Colors.white,
      onSurfaceVariant: isLight ? _lightOnSurfaceVariant : _darkOnSurfaceVariant,
      outline: isLight ? const Color(0xFF8A8A8A) : const Color(0xFF707070),
      outlineVariant: isLight ? const Color(0xFFD6D6D6) : const Color(0xFF303030),
      inverseSurface: isLight ? _darkSurface : _lightSurface,
      onInverseSurface: isLight ? Colors.white : Colors.black,
      inversePrimary: isLight ? Colors.white : Colors.black,
      surfaceTint: Colors.transparent,
    );
  }

  static AppThemeColors semanticColors(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return AppThemeColors(
      actionBackground: Colors.black,
      onActionBackground: Colors.white,
      success: isLight ? _lightSuccess : _darkSuccess,
      onSuccess: isLight ? _lightOnSuccess : _darkOnSuccess,
      successContainer: isLight ? _lightSuccessContainer : _darkSuccessContainer,
      onSuccessContainer: isLight ? _lightOnSuccessContainer : _darkOnSuccessContainer,
    );
  }

  static ThemeData buildTheme({
    required Brightness brightness,
    required bool dynamicColors,
    required ColorScheme? dynamicColorScheme,
  }) {
    final colorScheme = dynamicColors && dynamicColorScheme != null ? dynamicColorScheme : monochromeColorScheme(brightness);
    final semanticTheme = semanticColors(brightness);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'geist',
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true, scrolledUnderElevation: 0),
      extensions: [semanticTheme],
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: semanticTheme.actionBackground,
        foregroundColor: semanticTheme.onActionBackground,
      ),
    );
  }
}
