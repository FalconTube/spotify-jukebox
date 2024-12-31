import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_artist_filter.dart';

class ArtistFilter extends ConsumerWidget {
  const ArtistFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistFilter = ref.watch(chosenArtistFilterProvider);
    return SizedBox(
      // Added SizedBox to constrain the height of the ListView
      height: 40, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Make it horizontal
        itemCount: 26,
        itemBuilder: (context, index) {
          final letter = String.fromCharCode('A'.codeUnitAt(0) + index);
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              onPressed: () {
                ref.read(chosenArtistFilterProvider.notifier).state = letter;
                final genre = ref.read(chosenGenreFilterProvider);
                ref
                    .read(dataProvider.notifier)
                    .resetAndFetch(artistLetter: letter, genre: genre);
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.zero)),
                  backgroundColor: artistFilter == letter
                      ? Theme.of(context).colorScheme.inversePrimary
                      : null),
              child: Text(letter),
            ),
          );
        },
      ),
    );
  }
}
