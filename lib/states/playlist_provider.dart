import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/playlist.dart';
import 'package:jukebox_spotify_flutter/classes/spotifyuser.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';

final playlistProvider = FutureProvider<List<Playlist>>((ref) async {
  // Get user ID
  final api = await SpotifyApiService.api;
  final userUri = 'https://api.spotify.com/v1/me';
  final userOut = await api.get(userUri);
  final user = SpotifyUser.fromJson(userOut.data);
  Log.log(user.id);

  // Now get their playlist
  final playlistUri = 'https://api.spotify.com/v1/users/${user.id}/playlists';
  final out = await api.get(playlistUri);

  List<Playlist> playlists = [];
  final items = out.data["items"];
  for (final playlist in items) {
    playlists.add(Playlist.fromJson(playlist));
  }
  return playlists;
});

final isPlaylistSelected = StateProvider<bool>((ref) => false);
