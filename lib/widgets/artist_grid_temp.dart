import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';

import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
// For dropdown only
import 'package:jukebox_spotify_flutter/states/chosen_artist_filter.dart';

class ImageGrid extends ConsumerWidget {
  const ImageGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListAsyncValue = ref.watch(imageListProvider);
    final filter = ref.watch(chosenArtistFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Grid'),
        actions: [
          DropdownButton<String>(
            value: filter,
            onChanged: (String? newValue) {
              if (newValue != null) {
                Log.log(newValue);
                ref.read(chosenArtistFilterProvider.notifier).state = newValue;
              }
            },
            items: <String>['A', 'B']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(imageListProvider.notifier).refresh(),
        child: imageListAsyncValue.when(
          data: (imageList) => GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              final imageData = imageList[index];
              return Card(
                // Added a Card for a better visual
                child: CachedNetworkImage(
                  imageUrl: imageData.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
