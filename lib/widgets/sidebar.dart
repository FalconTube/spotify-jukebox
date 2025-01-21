import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/main.dart';
import 'package:jukebox_spotify_flutter/states/queue_provider.dart';
import 'package:jukebox_spotify_flutter/states/sidebar_visible_provider.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SidebarPlayer extends ConsumerStatefulWidget {
  const SidebarPlayer({super.key});

  @override
  ConsumerState<SidebarPlayer> createState() => SidebarPlayerState();
}

class SidebarPlayerState extends ConsumerState<SidebarPlayer> {
  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(queueProvider);
    final sidebarVisible = ref.watch(isSidebarVisible);

    // If screen is large, use default size
    // If screen is size, use full width
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final double sidebarWidth = isLargeScreen ? 200 : screenWidth;

    return sidebarVisible
        ? _Sidebar(queue: queue, sidebarWidth: sidebarWidth)
        : Container();
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.queue,
    required this.sidebarWidth,
  });

  final List<SimpleTrack> queue;
  final double sidebarWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sidebarWidth,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Upcoming Songs",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18))
              ],
            ),
          ),
          Expanded(
            child: queue.isEmpty
                ? Container()
                : ListView.builder(
                    // BUG: Spotify API or SDK don't have option to alter queue
                    //
                    // onReorder: (int oldIndex, int newIndex) {
                    //   // TODO: reorder list via API endpoint: https://developer.spotify.com/documentation/web-api/reference/reorder-or-replace-playlists-tracks
                    //
                    //   setState(() {
                    //     if (oldIndex < newIndex) {
                    //       newIndex -= 1;
                    //     }
                    //     final SimpleTrack item = queue.removeAt(oldIndex);
                    //     queue.insert(newIndex, item);
                    //   });
                    // },
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final track = queue[index];
                      return ListTile(
                          key: ValueKey(track.uri),
                          title: Text(track.name),
                          subtitle: Text(track.album.name),
                          // leading: Icon(Icons.music_note),
                          leading: track.getImage() != ""
                              ? FadeInImage.memoryNetwork(
                                  fadeInDuration:
                                      const Duration(milliseconds: 300),
                                  image: track.getImage(),
                                  fit: BoxFit.cover,
                                  placeholder: pl)
                              : Image.asset("assets/placeholder.png",
                                  fit: BoxFit.cover));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
