abstract class AppState {}

class AppInitial extends AppState {}

class AppLoaded extends AppState {
  AppLoaded(this.isDark);

  final bool isDark;
}
