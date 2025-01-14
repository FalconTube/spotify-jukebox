import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/main.dart';
import 'package:jukebox_spotify_flutter/states/queue_provider.dart';

class SidebarPlayer extends ConsumerStatefulWidget {
  const SidebarPlayer({super.key});

  @override
  ConsumerState<SidebarPlayer> createState() => SidebarPlayerState();
}

class SidebarPlayerState extends ConsumerState<SidebarPlayer> {
  // List<String> _upcomingSongs = [
  //   'Song 1',
  //   'Song 2',
  //   'Song 3',
  //   'Song 4',
  //   'Song 5',
  //   'Song 6',
  //   'Song 7',
  // ];
  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(queueProvider);
    return Container(
      width: 200,
      color: Colors.grey[900],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Upcoming Songs",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton.filled(
                    onPressed: () {
                      ref.read(queueProvider.notifier).refreshQueue();
                    },
                    icon: Icon(Icons.refresh))
              ],
            ),
          ),
          Expanded(
            child: queue.isEmpty
                ? Container()
                : ReorderableListView.builder(
                    onReorder: (int oldIndex, int newIndex) {
                      // TODO: reorder list via API endpoint: https://developer.spotify.com/documentation/web-api/reference/reorder-or-replace-playlists-tracks
                      // ref.read(queueProvider.notifier).state = List.from(queue)
                      //   ..move(oldIndex, newIndex);
                      // setState(() async {
                      //   if (oldIndex < newIndex) {
                      //     newIndex -= 1;
                      //   }
                      //   final String item = _upcomingSongs.removeAt(oldIndex);
                      //   _upcomingSongs.insert(newIndex, item);
                      // });
                    },
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
                              : Image.asset("favicon.png", fit: BoxFit.cover));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
