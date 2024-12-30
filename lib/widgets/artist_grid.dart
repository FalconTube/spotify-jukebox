import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';

class ArtistGrid extends ConsumerWidget {
  const ArtistGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListAsyncValue = ref.watch(imageListProvider);

    return imageListAsyncValue.when(
      data: (imageList) => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
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
    );
  }
}
