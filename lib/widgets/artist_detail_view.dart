import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/classes/album.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/main.dart';
import 'package:jukebox_spotify_flutter/states/detail_provider.dart';
import 'package:jukebox_spotify_flutter/states/queue_provider.dart';
import 'package:jukebox_spotify_flutter/widgets/sidebar.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class ArtistDetailView extends ConsumerWidget {
  const ArtistDetailView({super.key, required this.info});

  final Info info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Log.log(info.runtimeType);
    switch (info.runtimeType) {
      case ArtistCard:
        ArtistCard artist = info as ArtistCard;
        AsyncValue<List<SimpleTrack>> topTracks =
            ref.watch(topTracksProvider(artist));
        return ArtistOrAlbum(info: artist, tracks: topTracks);
      case AlbumCard:
        AlbumCard album = info as AlbumCard;
        AsyncValue<List<SimpleTrack>> albumTracks =
            ref.watch(albumTracksProvider(album));
        return ArtistOrAlbum(info: album, tracks: albumTracks);
      default:
        return CircularProgressIndicator();
    }
  }
}

class ArtistOrAlbum extends ConsumerWidget {
  final Info info;
  final AsyncValue<List<SimpleTrack>> tracks;

  const ArtistOrAlbum({
    super.key,
    required this.info,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: Row(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                TopBar(info: info),
                tracks.when(
                  data: (tracks) {
                    return MainList(tracks: tracks);
                    // return const Text("Error");
                  },
                  error: (error, stackTrace) {
                    return SliverToBoxAdapter(
                        child: Text("Error: $error, Trace: $stackTrace"));
                  },
                  loading: () {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                )
              ],
            ),
          ),
          SidebarPlayer()
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.info,
  });

  final Info info;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        expandedHeight: 350,
        elevation: 5,
        pinned: true,
        // forceElevated: true,
        floating: false,
        flexibleSpace: FlexibleSpaceBar(
            title: Text(info.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            background: info.getImage() != ""
                ? Hero(
                    tag: info.getImage(),
                    child: FadeInImage.memoryNetwork(
                      fadeInDuration: const Duration(milliseconds: 300),
                      image: info.getImage(),
                      fit: BoxFit.cover,
                      placeholder: pl,
                    ),
                  )
                : Image.asset("assets/placeholder.png", fit: BoxFit.cover)));
  }
}

class MainList extends ConsumerWidget {
  List<SimpleTrack> tracks;
  MainList({super.key, required this.tracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(childCount: tracks.length,
            (context, index) {
      final track = tracks[index];
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: ListTile(
                // isThreeLine: true,
                visualDensity: VisualDensity(vertical: 4),
                leading: track.getImage() != ""
                    ? FadeInImage.memoryNetwork(
                        fadeInDuration: const Duration(milliseconds: 300),
                        image: track.getImage(),
                        fit: BoxFit.fitHeight,
                        placeholder: pl,
                      )
                    : Image.asset("assets/placeholder.png", fit: BoxFit.cover),
                trailing: Material(
                  // Added Material for inkwell effect and elevation
                  color: Colors.transparent, // Make the background transparent
                  child: InkWell(
                    onTap: () async {
                      await SpotifySdk.queue(spotifyUri: track.uri);
                      await Future.delayed(Duration(milliseconds: 300));
                      ref.read(queueProvider.notifier).refreshQueue();
                    },
                    borderRadius: BorderRadius.circular(
                        24.0), // Optional: Rounded corners for the InkWell
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                            alpha: 0.5), // Semi-transparent background
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.queue_music,
                        color: Colors.white,
                        size: 36.0,
                      ),
                    ),
                  ),
                ),
                title: Text(track.name),
                subtitle: Text(track.prettyDuration())),
          ),
        ),
      );
    }));
  }
}
