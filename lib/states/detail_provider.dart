import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';

final topTracksProvider =
    FutureProvider.family<List<SimpleTrack>, ArtistCard>((ref, artist) async {
  final uri = 'https://api.spotify.com/v1/artists/${artist.id}/top-tracks';
  final api = await SpotifyApiService.api;
  final out = await api.get(uri);

  List<SimpleTrack> trackItems = [];
  final tracks = out.data["tracks"];
  for (final track in tracks) {
    trackItems.add(SimpleTrack.fromJson(track));
  }
  return trackItems;
});
