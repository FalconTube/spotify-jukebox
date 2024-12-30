import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';

import 'package:jukebox_spotify_flutter/states/chosen_artist_filter.dart';

// 2. Create an AsyncNotifierProvider to manage the image URLs
final imageListProvider =
    AsyncNotifierProvider<ImageListNotifier, List<ArtistCard>>(
        ImageListNotifier.new);

class ImageListNotifier extends AsyncNotifier<List<ArtistCard>> {
  @override
  Future<List<ArtistCard>> build() async {
    // If chosenArtist changes, we must update this list
    final artistLetter = ref.watch(chosenArtistFilterProvider);
    final genre = ref.watch(chosenGenreFilterProvider);
    final artists = await _getMostRelevantArtists(artistLetter, 9, genre);
    sortByFollowersDescending(artists);
    removeNotStartingWithLetter(artists, artistLetter);
    return artists;
    // return _fetchImages(artists);
  }

  // Sorts all artists by their amount of followers in descending order
  void sortByFollowersDescending(List<ArtistCard> artists) {
    artists.sort((a, b) => b.followers.compareTo(a.followers));
  }

  //
  // Sorts all artists by their amount of followers in descending order
  void removeNotStartingWithLetter(List<ArtistCard> artists, String letter) {
    artists.removeWhere((artist) => artist.name.startsWith(letter) == false);
    // artists.sort((a, b) => b.followers.compareTo(a.followers));
  }

  Future<List<ArtistCard>> _getMostRelevantArtists(
      String letter, int limit, String genre) async {
    String uri;

    if (genre == "") {
      uri =
          "https://api.spotify.com/v1/search?q=$letter&type=artist&limit=$limit";
    } else {
      uri =
          'https://api.spotify.com/v1/search?q=$letter genre:"$genre"&type=artist&limit=$limit';
    }

    final api = await SpotifyApiService.api;
    final out = await api.get(uri);
    // 'https://api.spotify.com/v1/search?q=$letter&type=artist&limit=$limit');
    final items = out.data["artists"]["items"];

    List<ArtistCard> foundArtists = [];
    for (final item in items) {
      final name = item["name"].toString();
      final pop = item["popularity"];
      final follows = item["followers"]["total"];
      final img = item["images"][0]["url"].toString();
      // Log.log("Name: $name, Pop: $pop, Fol: $follows Img: $img");
      foundArtists.add(ArtistCard(
          imageUrl: img, name: name, popularity: pop, followers: follows));
    }
    return foundArtists;
  }

  Future<void> refresh() async {
    state =
        const AsyncLoading(); // Important for showing loading state on refresh
    state = await AsyncValue.guard(() => _getMostRelevantArtists(
        ref.read(chosenArtistFilterProvider),
        4,
        ref.read(chosenGenreFilterProvider)));
  }
}
