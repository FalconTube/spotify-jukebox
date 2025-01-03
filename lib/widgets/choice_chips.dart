import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_filters.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';
import 'package:jukebox_spotify_flutter/types/request_type.dart';

class ChipRow extends ConsumerWidget {
  const ChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChip = ref.watch(chosenSearchFilter);
    const chipLabels = {
      RequestType.artist: 'Artists',
      RequestType.album: 'Albums',
      RequestType.track: 'Songs',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: chipLabels.keys.map((requestType) {
        return Padding(
          // Added padding for better spacing
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text(chipLabels[requestType]!),
            selected: selectedChip == requestType,
            onSelected: (selected) {
              ref.read(chosenSearchFilter.notifier).state = requestType;
              final query = ref.read(searchQueryProvider);
              final genre = ref.read(chosenGenreFilterProvider);
              ref.read(dataProvider.notifier).resetAndFetch(
                  searchQuery: query, genre: genre, requestType: requestType);
            },
          ),
        );
      }).toList(),
    );
  }
}
