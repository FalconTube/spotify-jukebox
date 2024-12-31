import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_artist_filter.dart';

class ArtistGrid extends ConsumerStatefulWidget {
  Uint8List placeholder;
  ArtistGrid({super.key, required this.placeholder});

  @override
  ConsumerState<ArtistGrid> createState() => _ArtistGridState();
}

class _ArtistGridState extends ConsumerState<ArtistGrid> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final artistLetter = ref.read(chosenArtistFilterProvider);
    final genre = ref.read(chosenGenreFilterProvider);
    if (_scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent * 2 / 3)) {
      ref.read(dataProvider.notifier).fetchData(artistLetter, genre);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataState = ref.watch(dataProvider);

    if (dataState.isLoading && dataState.data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dataState.error != null) {
      return Center(child: Text(dataState.error!));
    }

    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: dataState.data.length + (dataState.isLoading ? 1 : 0),
      // itemCount: imageList.length,
      itemBuilder: (context, index) {
        if (index < dataState.data.length) {
          final imageData = dataState.data[index];
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
                    child: imageData.imageUrl != ""
                        ? FadeInImage.memoryNetwork(
                            fadeInDuration: const Duration(milliseconds: 300),
                            image: imageData.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: widget.placeholder,
                          )
                        : Image.asset("favicon.png", fit: BoxFit.cover),
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
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
