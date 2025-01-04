import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/classes/album.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/main.dart';

import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_filters.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';
import 'package:jukebox_spotify_flutter/widgets/artist_detail_view.dart';

class ArtistGrid extends ConsumerStatefulWidget {
  final Uint8List placeholder;
  const ArtistGrid({super.key, required this.placeholder});

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
    final query = ref.read(searchQueryProvider);
    final genre = ref.read(chosenGenreFilterProvider);
    final requestType = ref.read(chosenSearchFilter);
    if (_scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent * 2 / 3)) {
      ref.read(dataProvider.notifier).fetchData(query, genre, requestType);
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

    // return Scaffold(body: dataState.,)
    return InnerArtistGrid(
        scrollController: _scrollController,
        dataState: dataState,
        widget: widget);
  }
}

class InnerArtistGrid extends StatelessWidget {
  const InnerArtistGrid({
    super.key,
    required ScrollController scrollController,
    required this.dataState,
    required this.widget,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final DataState dataState;
  final ArtistGrid widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 0,
        ),
        itemCount: dataState.data.length + (dataState.isLoading ? 1 : 0),
        // itemCount: imageList.length,
        itemBuilder: (context, index) {
          if (index < dataState.data.length) {
            final imageData = dataState.data[index];
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Card(
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return ArtistDetailView(info: imageData);
                      }),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (imageData is ArtistCard)
                        ArtistImage(imageData: imageData),

                      if (imageData is AlbumCard)
                        AlbumImage(imageData: imageData),

                      // AlbumImage(imageData: imageData),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          imageData.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis, // Handle long text
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ArtistImage extends StatelessWidget {
  const ArtistImage({
    super.key,
    required this.imageData,
  });

  final Info imageData;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: imageData.getImage() != ""
          ? Hero(
              tag: imageData.getImage(),
              child: CircleAvatar(
                backgroundImage: NetworkImage(imageData.getImage()),
              ),
            )
          : CircleAvatar(backgroundImage: AssetImage("favicon.png")),
    );
  }
}

class AlbumImage extends StatelessWidget {
  const AlbumImage({
    super.key,
    required this.imageData,
  });

  final Info imageData;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: imageData.getImage() != ""
          ? Hero(
              tag: imageData.getImage(),
              child: FadeInImage.memoryNetwork(
                fadeInDuration: const Duration(milliseconds: 300),
                image: imageData.getImage(),
                fit: BoxFit.cover,
                placeholder: pl,
              ),
            )
          : Image.asset("favicon.png", fit: BoxFit.cover),
    );
  }
}
