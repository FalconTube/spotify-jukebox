import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class QueueProvider extends StateNotifier<List<SimpleTrack>> {
  QueueProvider() : super([]); // Initial state is an empty string.

  void refreshQueue() async {
    final api = await SpotifyApiService.api;
    String uri = "https://api.spotify.com/v1/me/player/queue";
    // Disable cache for this request
    final out = await api.get(uri, withoutCache: true);
    final req = out.requestOptions.extra;
    Log.log(req);
    final queueItems = out.data["queue"];
    // Reset queue
    var queueTracks = <SimpleTrack>[];

    for (final item in queueItems) {
      queueTracks.add(SimpleTrack.fromJson(item));
    }
    // Log.log("Data: ${out.data}");
    // Log.log("Items: $queueItems");

    state = queueTracks;
  }

  void updateQueue(List<SimpleTrack> queue) async {}
}

final queueProvider =
    StateNotifierProvider<QueueProvider, List<SimpleTrack>>((ref) {
  return QueueProvider();
});
