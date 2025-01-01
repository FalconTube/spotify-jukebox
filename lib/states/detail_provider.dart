import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';

final topTracksProvider =
    FutureProvider.family<List<SimpleTrack>, ArtistCard>((ref, artist) async {
  final uri = 'https://api.spotify.com/v1/artists/${artist.id}/top-tracks';
  final api = await SpotifyApiService.api;
  final out = await api.get(uri);

  List<SimpleTrack> trackItems = [];
  final tracks = out.data["tracks"];
  for (final track in tracks) {
    final trackName = track["name"].toString();
    final duration = track["duration_ms"].toInt();
    String trackImg;
    final images = track["album"]["images"];
    if (images.toString() == "[]") {
      trackImg = "";
    } else {
      trackImg = images[0]["url"].toString();
    }
    trackItems.add(SimpleTrack(
        name: trackName,
        artistName: artist.name,
        img: trackImg,
        durationMs: duration));
  }
  return trackItems;
});
