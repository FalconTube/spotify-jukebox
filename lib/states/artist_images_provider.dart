import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';

import 'package:jukebox_spotify_flutter/states/chosen_artist_filter.dart';

// Provider for managing the data and API calls
final dataProvider = StateNotifierProvider<DataNotifier, DataState>((ref) {
  return DataNotifier();
});

// State for the data provider
class DataState {
  final List<ArtistCard> data;
  final bool isLoading;
  final String? error;
  final int page; // Keep track of the current page

  DataState({
    this.data = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
  });

  DataState copyWith({
    List<ArtistCard>? data,
    bool? isLoading,
    String? error,
    int? page,
  }) {
    return DataState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
    );
  }
}

class DataNotifier extends StateNotifier<DataState> {
  DataNotifier() : super(DataState()) {
    fetchData("A", ""); // Initial data fetch
  }
  void resetAndFetch({required String artistLetter, required String genre}) {
    state = DataState(); // Reset state to initial values.
    fetchData(artistLetter, genre); // Fetch with the new URL
  }

  Future<void> fetchData(String artistLetter, String genre) async {
    if (state.isLoading) return; // Prevent concurrent requests

    state = state.copyWith(isLoading: true, error: null);
    int currentAmountItems = state.data.length;
    final artists = await _getMostRelevantArtists(
        artistLetter, 20, genre, currentAmountItems);
    sortByFollowersDescending(artists);
    removeNotStartingWithLetter(artists, artistLetter);
    // Remove possible duplicates
    if (currentAmountItems > 1) {
      final distinctArtists = removeAlreadyExisting(state.data, artists);
      state = state.copyWith(
        data: [...state.data, ...distinctArtists], // Append new data
        isLoading: false,
        page: state.page + 1, // Increment page number
      );
    } else {
      state = state.copyWith(
        data: [...state.data, ...artists], // Append new data
        isLoading: false,
        page: state.page + 1, // Increment page number
      );
    }
  }

  //
  // Sorts all artists by their amount of followers in descending order
  void sortByFollowersDescending(List<ArtistCard> artists) {
    artists.sort((a, b) => b.followers.compareTo(a.followers));
  }

  // Sorts all artists by their amount of followers in descending order
  void removeNotStartingWithLetter(List<ArtistCard> artists, String letter) {
    artists.removeWhere((artist) => artist.name.startsWith(letter) == false);
    // artists.sort((a, b) => b.followers.compareTo(a.followers));
  }

  List<ArtistCard> removeAlreadyExisting(
      List<ArtistCard> curArt, List<ArtistCard> newArt) {
    // Create list of names of artists
    List<String> curArtNames = [];
    for (final artist in curArt) {
      // Log.log(artist.toString());
      curArtNames.add(artist.name);
    }
    // Now check if they are already present in existing
    List<ArtistCard> distinctArtists = [];
    for (final artist in newArt) {
      if (curArtNames.contains(artist.name)) {
        continue;
      }
      distinctArtists.add(artist);
    }

    return distinctArtists;
  }

  List<ArtistCard> removeDuplicates(List<ArtistCard> artists) {
    final distinctArtists = LinkedHashSet<ArtistCard>.from(artists).toList();
    return distinctArtists;
  }

  Future<List<ArtistCard>> _getMostRelevantArtists(
      String letter, int limit, String genre, int offset) async {
    String uri;

    if (genre == "") {
      uri =
          "https://api.spotify.com/v1/search?q=$letter&type=artist&limit=$limit&offset=$offset";
    } else {
      uri =
          'https://api.spotify.com/v1/search?q=$letter genre:"$genre"&type=artist&limit=$limit&offset=$offset';
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
}
