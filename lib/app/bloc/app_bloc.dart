import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial()) {
    on<AppStarted>((event, emit) {
      // Initialize app, e.g., load theme from prefs
      emit(AppLoaded(false)); // Default to light theme
    });

    on<AppThemeChanged>((event, emit) {
      if (state is AppLoaded) {
        emit(AppLoaded(event.isDark));
      }
    });
  }
}
