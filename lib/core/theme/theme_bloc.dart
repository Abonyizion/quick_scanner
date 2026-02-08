import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _themeKey = 'is_dark_mode';

  ThemeBloc() : super(const ThemeState(isDarkMode: false)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);

    //  load persisted theme immediately
    add(LoadThemeEvent());
  }

  Future<void> _onLoadTheme(
      LoadThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(ThemeState(isDarkMode: isDark));
  }

  Future<void> _onToggleTheme(
      ToggleThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    final newValue = !state.isDarkMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newValue);

    emit(ThemeState(isDarkMode: newValue));
  }
}
