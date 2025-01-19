import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/classes/album.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/main.dart';

import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_filters.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';
import 'package:jukebox_spotify_flutter/states/settings_provider.dart';
import 'package:jukebox_spotify_flutter/widgets/artist_detail_view.dart';
import 'package:jukebox_spotify_flutter/widgets/no_playlist_selected_placeholder.dart';
import 'package:jukebox_spotify_flutter/widgets/search_placeholder.dart';

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
    final searchResultAmount = ref.read(settingsProvider).searchResultAmount;
    if (_scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent * 2 / 3)) {
      ref
          .read(dataProvider.notifier)
          .fetchData(query, genre, requestType, searchResultAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataState = ref.watch(dataProvider);

    if (dataState.isLoading && dataState.data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!dataState.isLoading && dataState.data.isEmpty) {
      return const Center(child: SearchPlaceholderCard());
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
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300
            // crossAxisSpacing: 8,
            // mainAxisSpacing: 0,
            ),
        // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //   crossAxisCount: 3,
        //   crossAxisSpacing: 8,
        //   mainAxisSpacing: 0,
        // ),
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
                    if (imageData is SimpleTrack) return;
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

                      if (imageData is SimpleTrack)
                        PlayableNetworkImage(imageUrl: imageData.getImage()),

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

class PlayableNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double imageWidth;
  final double imageHeight;

  const PlayableNetworkImage({
    super.key,
    required this.imageUrl,
    this.imageWidth = double.infinity,
    this.imageHeight = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand, // Important: Makes the image fill the SizedBox
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, object, stackTrace) {
              return const Center(
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          ),
          Positioned(
            bottom: 8.0, // Adjust as needed
            right: 8.0, // Adjust as needed
            child: Material(
              // Added Material for inkwell effect and elevation
              color: Colors.transparent, // Make the background transparent
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(
                    24.0), // Optional: Rounded corners for the InkWell
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withValues(alpha: 0.9), // Semi-transparent background
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 36.0,
                  ),
                ),
              ),
            ),
          ),
        ],
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
          : CircleAvatar(backgroundImage: AssetImage("assets/placeholder.png")),
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
          : Image.asset("assets/placeholder.png", fit: BoxFit.cover),
    );
  }
}
