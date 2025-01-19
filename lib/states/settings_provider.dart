import 'dart:convert';

import 'package:jukebox_spotify_flutter/classes/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This provides the actual settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences? _prefs;

  SettingsNotifier(this._prefs) : super(_loadSettings(_prefs)) {
    // Initialize from SharedPreferences on startup
  }

  static AppSettings _loadSettings(SharedPreferences? prefs) {
    if (prefs != null) {
      final settingsJson = prefs.getString('app_settings');
      if (settingsJson != null) {
        try {
          return AppSettings.fromJson(jsonDecode(settingsJson));
        } catch (e) {
          Log.log('Error loading settings: $e');
        }
      }
    }
    return AppSettings(
        showVirtualKeyboard: true, showTypeFilters: true, debounceDelay: 1500);
  }

  Future<void> updateShowVirtualKeyboard(bool value) async {
    state = state.copyWith(showVirtualKeyboard: value);
    await _saveSettings();
  }

  Future<void> updateShowTypeFilters(bool value) async {
    state = state.copyWith(showTypeFilters: value);
    await _saveSettings();
  }

  Future<void> updateDebounceDelay(double value) async {
    state = state.copyWith(debounceDelay: value);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    await _prefs!.setString('app_settings', jsonEncode(state.toJson()));
  }
}

// Settings Provider (using StateNotifierProvider)
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  // Use .when to handle the FutureProvider's state
  final prefsAsyncValue = ref.watch(sharedPreferencesProvider);
  return prefsAsyncValue.when(
    data: (prefs) => SettingsNotifier(prefs),
    loading: () =>
        SettingsNotifier(null), // Provide a default or handle loading
    error: (error, stackTrace) {
      Log.log('Error loading SharedPreferences: $error');
      return SettingsNotifier(null);
    },
  );
});

// This loads shared prefs async
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});
