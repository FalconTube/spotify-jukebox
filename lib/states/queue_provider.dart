import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';

class QueueProvider extends StateNotifier<List<SimpleTrack>> {
  QueueProvider() : super([]); // Initial state is an empty string.

  Future<void> refreshQueue() async {
    final api = await SpotifyApiService.api;
    String uri = "https://api.spotify.com/v1/me/player/queue";
    // Disable cache for this request
    final out = await api.get(uri, withoutCache: true);
    final queueItems = out.data["queue"];
    // Reset queue
    var queueTracks = <SimpleTrack>[];

    for (final item in queueItems) {
      queueTracks.add(SimpleTrack.fromJson(item));
    }

    state = queueTracks;
  }

  void updateQueue(List<SimpleTrack> queue) async {}
}

final queueProvider =
    StateNotifierProvider<QueueProvider, List<SimpleTrack>>((ref) {
  return QueueProvider();
});
