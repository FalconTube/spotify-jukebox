import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/main.dart';
import 'package:jukebox_spotify_flutter/states/detail_provider.dart';
import 'package:jukebox_spotify_flutter/types/request_type.dart';

class DetailView extends ConsumerWidget {
  const DetailView({super.key, required this.info});

  final Info info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (info.type != RequestType.artist) return CircularProgressIndicator();
    final artist = ArtistCard.fromSuperclass(info, "", 0);
    final topTracks = ref.watch(topTracksProvider(artist));
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
              expandedHeight: 350,
              elevation: 5,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  title: Text(artist.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  background: artist.imageUrl != ""
                      ? Hero(
                          tag: artist.imageUrl,
                          child: FadeInImage.memoryNetwork(
                            fadeInDuration: const Duration(milliseconds: 300),
                            image: artist.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: pl,
                          ),
                        )
                      : Image.asset("favicon.png", fit: BoxFit.cover))),
          topTracks.when(
            data: (tracks) {
              return SliverList(
                  delegate: SliverChildBuilderDelegate(
                      childCount: tracks.length, (context, index) {
                final track = tracks[index];
                Log.log("Index: $index, all: ${tracks.length}");
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: ListTile(
                          visualDensity: VisualDensity(vertical: 4),
                          leading: track.imageUrl != ""
                              ? FadeInImage.memoryNetwork(
                                  fadeInDuration:
                                      const Duration(milliseconds: 300),
                                  image: track.imageUrl,
                                  fit: BoxFit.fitHeight,
                                  placeholder: pl,
                                )
                              : Image.asset("favicon.png", fit: BoxFit.cover),
                          trailing: Text(
                            track.prettyDuration(),
                          ),
                          title: Text(track.name)),
                    ),
                  ),
                );
              }));
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
    );
  }
}
