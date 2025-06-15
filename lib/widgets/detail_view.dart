import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/album.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/classes/playlist.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/main.dart';
import 'package:jukebox_spotify_flutter/states/detail_provider.dart';
import 'package:jukebox_spotify_flutter/states/playlist_provider.dart';
import 'package:jukebox_spotify_flutter/states/queue_provider.dart';
import 'package:jukebox_spotify_flutter/widgets/sidebar.dart';
import 'package:quickalert/quickalert.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class DetailView extends ConsumerWidget {
  const DetailView({super.key, required this.info});

  final Info info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (info.runtimeType) {
      case const (ArtistCard):
        ArtistCard artist = info as ArtistCard;
        AsyncValue<List<SimpleTrack>> topTracks =
            ref.watch(topTracksProvider(artist));
        return DetailList(info: artist, tracks: topTracks);
      case const (AlbumCard):
        AlbumCard album = info as AlbumCard;
        AsyncValue<List<SimpleTrack>> albumTracks =
            ref.watch(albumTracksProvider(album));
        return DetailList(info: album, tracks: albumTracks);
      case const (Playlist):
        Playlist playlist = info as Playlist;
        AsyncValue<List<SimpleTrack>> playlistTracks =
            ref.watch(playlistTracksProvider(playlist));
        return DetailList(info: playlist, tracks: playlistTracks);
      default:
        return CircularProgressIndicator();
    }
  }
}

class DetailList extends ConsumerWidget {
  final Info info;
  final AsyncValue<List<SimpleTrack>> tracks;

  const DetailList({
    super.key,
    required this.info,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaylist = info is Playlist;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: isPlaylist
          ? FloatingActionButton.extended(
              onPressed: () async {
                final api = await SpotifyApiService.api;
                await api.playOrSelectPlaylist(info.id, selectOnly: true);

                ref.read(isPlaylistSelected.notifier).update((state) => true);
              },
              label: Text('Select Playlist'))
          : null,
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  gradient: RadialGradient(
                      center: Alignment(-0.4, -0.2),
                      radius: 2.2,
                      colors: [
                    Theme.of(context).colorScheme.surfaceContainerLowest,
                    Theme.of(context).colorScheme.surfaceContainer,
                  ])),
              child: CustomScrollView(
                slivers: <Widget>[
                  TopBar(info: info),
                  tracks.when(
                    data: (tracks) {
                      return MainList(tracks: tracks);
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
        surfaceTintColor: Theme.of(context).colorScheme.primaryContainer,
        expandedHeight: 350,
        elevation: 5,
        pinned: true,
        floating: false,
        leading: InkWell(
          borderRadius: BorderRadius.circular(20), // Circular shape
          onTap: () {
            Navigator.of(context).maybePop();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40, // Adjust size as needed
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded, // Use a modern back arrow
                  size: 20, // Adjust icon size
                ),
              ),
            ),
          ),
        ),
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
  final List<SimpleTrack> tracks;
  const MainList({super.key, required this.tracks});

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
            child: Column(
              children: [
                ListTile(
                    // isThreeLine: true,
                    // tileColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                    visualDensity: VisualDensity(vertical: 4),
                    leading: track.getImage() != ""
                        ? FadeInImage.memoryNetwork(
                            fadeInDuration: const Duration(milliseconds: 300),
                            image: track.getImage(),
                            fit: BoxFit.fitHeight,
                            placeholder: pl,
                          )
                        : Image.asset("assets/placeholder.png",
                            fit: BoxFit.cover),
                    trailing: Material(
                      // Added Material for inkwell effect and elevation
                      color:
                          Colors.transparent, // Make the background transparent
                      child: InkWell(
                        onTap: () async {
                          if (context.mounted) {
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: "Success",
                                text: "Song added to queue!",
                                autoCloseDuration: Duration(seconds: 5),
                                showConfirmBtn: true,
                                confirmBtnColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainer,
                                titleColor:
                                    Theme.of(context).colorScheme.onSurface,
                                textColor:
                                    Theme.of(context).colorScheme.onSurface,
                                confirmBtnTextStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface));
                          }
                          await SpotifySdk.queue(spotifyUri: track.uri);
                          await Future.delayed(Duration(milliseconds: 300));
                          ref.read(queueProvider.notifier).refreshQueue();
                        },
                        borderRadius: BorderRadius.circular(
                            24.0), // Optional: Rounded corners for the InkWell
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.queue_music,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            size: 36.0,
                          ),
                        ),
                      ),
                    ),
                    title: Text(track.name),
                    subtitle: Text(track.prettyDuration())),
                Divider(height: 20)
              ],
            ),
          ),
        ),
      );
    }));
  }
}
