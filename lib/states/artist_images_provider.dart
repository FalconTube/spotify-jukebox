import 'dart:collection';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/classes/response_data.dart';
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
    fetchData("A", "", []); // Initial data fetch
  }
  void resetAndFetch(
      {required String searchQuery,
      required String genre,
      required List<RequestType> requestType}) {
    state = DataState(); // Reset state to initial values.
    fetchData(searchQuery, genre, requestType); // Fetch with the new URL
  }

  Future<void> fetchData(
      String searchQuery, String genre, List<RequestType> requestType) async {
    if (state.isLoading) return; // Prevent concurrent requests
    if (searchQuery == "") return; // Nothing to do if empty

    state = state.copyWith(isLoading: true, error: null);
    int currentAmountItems = state.data.length;
    final infos = await _requestInfo(
        searchQuery, 2, genre, currentAmountItems, requestType);
    // sortByFollowersDescending(infos);
    // sortByPopularityDescending(infos);
    // removeNotStartingWithLetter(infos, "f");
    removeWithoutGenre(infos);
    removeHoerspiel(infos);
    // Remove possible duplicates
    if (currentAmountItems > 1) {
      final distinctInfos = removeAlreadyExisting(state.data, infos);
      state = state.copyWith(
        data: [...state.data, ...distinctInfos], // Append new data
        isLoading: false,
        page: state.page + 1, // Increment page number
      );
    } else {
      state = state.copyWith(
        data: [...state.data, ...infos], // Append new data
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
  void removeWithoutGenre(List<Info> infos) {
    infos.removeWhere((info) {
      if (info is ArtistCard) return info.genres!.isEmpty;
      return false;
    });
  }

  // We do not want "Hoerspiel"
  void removeHoerspiel(List<Info> infos) {
    infos.removeWhere((info) {
      if (info is ArtistCard) return info.genres!.contains("hoerspiel");
      return false;
    });
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

  List<Info> removeDuplicates(List<Info> artists) {
    final distinctInfos = LinkedHashSet<Info>.from(artists).toList();
    return distinctInfos;
  }

  Future<List<Info>> _requestInfo(String letter, int limit, String genre,
      int offset, List<RequestType> type) async {
    String uri;
    String typeFilter;
    // If no value give, search for all
    if (type.isEmpty) {
      // typeFilter = "&type=${RequestType.artist.name}";
      typeFilter =
          "&type=${RequestType.artist.name},${RequestType.album.name},${RequestType.track.name}";
    } else {
      typeFilter = "&type=${type.join(",")}";
    }

    if (genre == "") {
      uri =
          "https://api.spotify.com/v1/search?q=${letter.toUpperCase()}$typeFilter&limit=$limit&offset=$offset";
    } else {
      uri =
          'https://api.spotify.com/v1/search?q=${letter.toUpperCase()} genre:"$genre"$typeFilter&limit=$limit&offset=$offset';
    }
    Log.log(uri);

    final api = await SpotifyApiService.api;
    final out = await api.get(uri);
    final ResponseData response = ResponseData.fromJson(out.data);

    // Flutter magic
    // Iterate over all items per category and append to list
    List<Info> allOutputs = [
      ...?response.artists?.items,
      ...?response.albums?.items,
      ...?response.tracks?.items,
    ];

    return allOutputs;
  }
}
