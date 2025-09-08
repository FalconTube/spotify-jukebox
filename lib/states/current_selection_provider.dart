import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';

class CurrentSelectionProvider extends StateNotifier<Info?> {
  CurrentSelectionProvider() : super(null); // Initial state is an empty string.

  void updateSelection(Info currentSelection) {
    state = currentSelection;
  }

  void clearSelection() {
    state = null;
  }
}

final currentSelectionProvider =
    StateNotifierProvider<CurrentSelectionProvider, Info?>((ref) {
  return CurrentSelectionProvider();
});
