import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';

class ArtistGrid extends ConsumerWidget {
  ArtistGrid({super.key, required this.placeholder});
  Uint8List placeholder;

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
            elevation: 5,
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FadeInImage.memoryNetwork(
                      image: imageData.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: placeholder,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      imageData.name,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis, // Handle long text
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // loading: () => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
