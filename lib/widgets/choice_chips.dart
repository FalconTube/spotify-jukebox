import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/states/data_query_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_filters.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';
import 'package:jukebox_spotify_flutter/states/settings_provider.dart';
import 'package:jukebox_spotify_flutter/types/request_type.dart';

class ChipRow extends ConsumerWidget {
  const ChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChips = ref.watch(chosenSearchFilter);
    final chipNotifier = ref.watch(chosenSearchFilter.notifier);
    final settings = ref.watch(settingsProvider);

    const chipLabels = ['Artists', 'Albums', 'Songs', 'Playlists'];
    const chipValues = {
      RequestType.artist: 'Artists',
      RequestType.album: 'Albums',
      RequestType.track: 'Songs',
      RequestType.playlist: 'Playlists'
    };

    return Wrap(
      children: List<Widget>.generate(chipValues.keys.length, (int index) {
        final option = chipValues.keys.toList()[index];
        final isSelected = selectedChips.contains(option);
        return settings.showTypeFilters
            ? Padding(
                // Added padding for better spacing
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: Text(chipLabels[index]),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) {
                      // Add option to selected chips
                      chipNotifier.state = [...selectedChips, option];
                    } else {
                      // Remove option from selected chips
                      chipNotifier.state =
                          selectedChips.where((o) => o != option).toList();
                    }
                    final query = ref.read(searchQueryProvider);
                    final genre = ref.read(chosenGenreFilterProvider);
                    final searchResultAmount =
                        ref.read(settingsProvider).searchResultAmount;
                    ref.read(dataProvider.notifier).resetAndFetch(
                        searchQuery: query,
                        genre: genre,
                        requestType: chipNotifier.state,
                        searchResultAmount: searchResultAmount);
                  },
                ),
              )
            : Center();
      }).toList(),
    );
  }
}
