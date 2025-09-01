import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';

class TrackDurationProvider extends StateNotifier<int> {
  TrackDurationProvider() : super(0); // Initial state is an empty string.

  Future<void> getTrackDuration(String fullTrackUri) async {
    final trimmed = fullTrackUri.split(":").last;
    final api = await SpotifyApiService.api;
    final trackDuration = await api.getTrackDuration(trimmed);

    state = trackDuration;
  }
}

final trackDurationProvider =
    StateNotifierProvider<TrackDurationProvider, int>((ref) {
  return TrackDurationProvider();
});
