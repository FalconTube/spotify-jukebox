import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/album.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/classes/playlist.dart';
import 'package:jukebox_spotify_flutter/classes/simplified_track_object.dart';
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
    trackItems.add(SimpleTrack.fromJson(track));
  }
  return trackItems;
});

final albumTracksProvider =
    FutureProvider.family<List<SimpleTrack>, AlbumCard>((ref, info) async {
  final uri = 'https://api.spotify.com/v1/albums/${info.id}/tracks';
  //
  // Now we have valid uri
  final api = await SpotifyApiService.api;
  final simpleResponse = await api.get(uri);

  // First get all simple track objects from api
  final tracks = simpleResponse.data["items"];
  List<SimplifiedTrackObject> simpleTracks = [];
  for (final track in tracks) {
    simpleTracks.add(SimplifiedTrackObject.fromJson(track));
  }

  // Get ids of simple track objects
  final String ids = simpleTracks.join(',');
  final tracksUri = 'https://api.spotify.com/v1/tracks?ids=$ids';
  final fullResponse = await api.get(tracksUri);

  // Now get real track infos
  List<SimpleTrack> trackItems = [];
  final fullTracks = fullResponse.data["tracks"];
  for (final track in fullTracks) {
    trackItems.add(SimpleTrack.fromJson(track));
  }
  return trackItems;
});

final playlistTracksProvider =
    FutureProvider.family<List<SimpleTrack>, Playlist>((ref, info) async {
  final uri = 'https://api.spotify.com/v1/playlists/${info.id}/tracks';

  final api = await SpotifyApiService.api;
  final fullResponse = await api.get(uri);
  Log.log(fullResponse);

  // Get tracks
  List<SimpleTrack> trackItems = [];
  final items = fullResponse.data["items"];
  Log.log(trackItems);
  for (final track in items) {
    trackItems.add(SimpleTrack.fromJson(track["track"]));
  }
  return trackItems;
});
