import 'dart:collection';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/types/request_type.dart';

// Provider for managing the data and API calls
final dataProvider = StateNotifierProvider<DataNotifier, DataState>((ref) {
  return DataNotifier();
});

// State for the data provider
class DataState {
  final List<Info> data;
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
    List<Info>? data,
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
    fetchData("A", "", RequestType.artist); // Initial data fetch
  }
  void resetAndFetch(
      {required String searchQuery,
      required String genre,
      required RequestType requestType}) {
    state = DataState(); // Reset state to initial values.
    fetchData(searchQuery, genre, requestType); // Fetch with the new URL
  }

  Future<void> fetchData(
      String searchQuery, String genre, RequestType requestType) async {
    if (state.isLoading) return; // Prevent concurrent requests
    if (searchQuery == "") return; // Nothing to do if empty

    state = state.copyWith(isLoading: true, error: null);
    int currentAmountItems = state.data.length;
    final artists = await _requestInfo(
        searchQuery, 2, genre, currentAmountItems, requestType);
    // sortByFollowersDescending(artists);
    // sortByPopularityDescending(artists);
    // removeNotStartingWithLetter(artists, "f");
    removeWithoutGenre(artists);
    removeHoerspiel(artists);
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
  // void sortByFollowersDescending(List<ArtistCard> artists) {
  //   artists.sort((a, b) => b.followers.compareTo(a.followers));
  // }

  // Sorts all artists by their amount of popularity in descending order
  void sortByPopularityDescending(List<ArtistCard> artists) {
    artists.sort((a, b) => b.popularity.compareTo(a.popularity));
  }

  void removeNotStartingWithLetter(List<Info> artists, String letter) {
    artists.removeWhere((artist) =>
        artist.name.toLowerCase().startsWith(letter.toLowerCase()) == false);
    // artists.sort((a, b) => b.followers.compareTo(a.followers));
  }

  // Some things do not have a genre.
  // I guess they are not music then, so remove them.
  void removeWithoutGenre(List<ArtistCard> artists) {
    artists.removeWhere((artist) => artist.genres!.isEmpty);
  }

  // We do not want "Hoerspiel"
  void removeHoerspiel(List<ArtistCard> artists) {
    artists.removeWhere((artist) => artist.genres!.contains("hoerspiel"));
  }

  List<Info> removeAlreadyExisting(List<Info> curArt, List<Info> newArt) {
    // Create list of names of artists
    List<String> curArtNames = [];
    for (final artist in curArt) {
      curArtNames.add(artist.name);
    }
    // Now check if they are already present in existing
    List<Info> distinctArtists = [];
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

  Future<List<ArtistCard>> _requestInfo(String letter, int limit, String genre,
      int offset, RequestType type) async {
    String uri;

    if (genre == "") {
      uri =
          // "https://api.spotify.com/v1/search?q=${letter.toUpperCase()}&type=artist,track,album&limit=$limit&offset=$offset";
          "https://api.spotify.com/v1/search?q=${letter.toUpperCase()}&type=${type.name}&limit=$limit&offset=$offset";
      // "https://api.spotify.com/v1/search?q=${letter.toUpperCase()}&type=track&limit=$limit&offset=$offset";
    } else {
      uri =
          'https://api.spotify.com/v1/search?q=${letter.toUpperCase()} genre:"$genre"&type=artist&limit=$limit&offset=$offset';
    }

    final api = await SpotifyApiService.api;
    final out = await api.get(uri);
    // 'https://api.spotify.com/v1/search?q=$letter&type=artist&limit=$limit');
    final items = out.data["artists"]["items"];

    List<ArtistCard> foundArtists = [];
    for (final item in items) {
      foundArtists.add(ArtistCard.fromJson(item));
    }
    return foundArtists;
  }
}
