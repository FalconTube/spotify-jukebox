import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_filters.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';

class GenreFilter extends ConsumerWidget {
  const GenreFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreFilter = ref.watch(chosenGenreFilterProvider);
    final genres = [
      "metal",
      "pop",
      "disco",
      "eurobeat",
    ];
    return SizedBox(
      // Added SizedBox to constrain the height of the ListView
      height: 40, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Make it horizontal
        itemCount: genres.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              onPressed: () {
                ref.read(chosenGenreFilterProvider.notifier).state =
                    genres[index];
                final query = ref.read(searchQueryProvider);
                final requestType = ref.read(chosenSearchFilter);
                ref.read(dataProvider.notifier).resetAndFetch(
                    searchQuery: query,
                    genre: genres[index],
                    requestType: requestType);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.zero)),
                backgroundColor: genreFilter == genres[index]
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              ),
              child: Text(genres[index]),
            ),
          );
        },
      ),
    );
  }
}
