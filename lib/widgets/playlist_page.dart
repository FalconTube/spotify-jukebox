import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/classes/playlist.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/states/playlist_provider.dart';

class PlaylistGridPage extends ConsumerStatefulWidget {
  const PlaylistGridPage({super.key});

  @override
  PlaylistGridPageState createState() => PlaylistGridPageState();
}

class PlaylistGridPageState extends ConsumerState<PlaylistGridPage> {
  Playlist? _selectedValue;

  @override
  Widget build(BuildContext context) {
    final playlistItems = ref.watch(playlistProvider);
    // if (playlistItems.isLoading && playlistItems.data.isEmpty) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Text("Playlist Selection")),
        body: switch (playlistItems) {
          AsyncData(:final value) => Material(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.8, // Adjust as needed for card height
                ),
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final playlist = value[index];
                  return InkWell(
                    // Use InkWell for tap detection and visual feedback
                    onTap: () {
                      setState(() {
                        _selectedValue = playlist;
                        Log.log("Selected playlist: $_selectedValue");
                      });
                    },
                    child: Card(
                      elevation: 4, // Add elevation for a card-like appearance
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                        side: _selectedValue == playlist
                            ? BorderSide(color: Colors.blue, width: 2)
                            : BorderSide.none,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, // Ensure image fills width
                        children: [
                          Expanded(
                            child: ClipRRect(
                              // Clip image to rounded corners
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child: Image.network(
                                playlist.getImage(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              playlist.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          AsyncError(:final error, :final stackTrace) =>
            Text("error $error, Stacktrace $stackTrace"),
          _ => CircularProgressIndicator(),
        },
        floatingActionButton: _selectedValue != null
            ? FloatingActionButton.extended(
                icon: Icon(Icons.check),
                onPressed: () async {
                  final api = await SpotifyApiService.api;
                  await api.playOrSelectPlaylist(_selectedValue!.id,
                      selectOnly: true);

                  ref.read(isPlaylistSelected.notifier).update((state) => true);
                  if (context.mounted) Navigator.pop(context);
                },
                label: Text("Choose Playlist"))
            : null);
  }
}
