import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';

import 'package:jukebox_spotify_flutter/states/chosen_artist_filter.dart';

// 2. Create an AsyncNotifierProvider to manage the image URLs
final imageListProvider =
    AsyncNotifierProvider<ImageListNotifier, List<ArtistCard>>(
        ImageListNotifier.new);

class ImageListNotifier extends AsyncNotifier<List<ArtistCard>> {
  @override
  Future<List<ArtistCard>> build() async {
    // If chosenArtist changes, we must update this list
    final filterValue = ref.watch(chosenArtistFilterProvider);
    return _fetchImages(filterValue);
  }

  Future<List<ArtistCard>> _fetchImages(String filter) async {
    // Replace this with your actual image fetching logic based on the filter
    if (filter == 'A') {
      return [
        ArtistCard(imageUrl: 'https://placekitten.com/200/300'),
        ArtistCard(imageUrl: 'https://placekitten.com/301/301'),
        ArtistCard(imageUrl: 'https://placekitten.com/202/302'),
      ];
    } else if (filter == 'B') {
      return [
        ArtistCard(imageUrl: 'https://placedog.net/500/280'),
        ArtistCard(imageUrl: 'https://placedog.net/501/281'),
        ArtistCard(imageUrl: 'https://placedog.net/502/282'),
      ];
    } else {
      return [];
    }
  }

  Future<void> refresh() async {
    state =
        const AsyncLoading(); // Important for showing loading state on refresh
    state = await AsyncValue.guard(
        () => _fetchImages(ref.read(chosenArtistFilterProvider)));
  }
}
