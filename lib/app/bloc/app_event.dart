abstract class AppEvent {}

class AppStarted extends AppEvent {}

class AppThemeChanged extends AppEvent {
  AppThemeChanged(this.isDark);

  final bool isDark;
}
