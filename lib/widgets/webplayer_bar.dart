import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/states/admin_enabled_provider.dart';
import 'package:jukebox_spotify_flutter/states/queue_provider.dart';
import 'package:spotify_sdk/models/album.dart';
import 'package:spotify_sdk/models/artist.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_options.dart' as playOptions;
import 'package:spotify_sdk/models/player_restrictions.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/enums/repeat_mode_enum.dart' as prefix;

// class SidebarPlayer extends ConsumerStatefulWidget {
//   const SidebarPlayer({super.key});
//
//   @override
//   ConsumerState<SidebarPlayer> createState() => SidebarPlayerState();
// }
//
// class SidebarPlayerState extends ConsumerState<SidebarPlayer> {

class WebPlayerBottomBar extends ConsumerStatefulWidget {
  const WebPlayerBottomBar({super.key});

  @override
  WebPlayerBottomBarState createState() => WebPlayerBottomBarState();
}

class WebPlayerBottomBarState extends ConsumerState<WebPlayerBottomBar> {
  @override
  Widget build(BuildContext context) {
    return buildPlayerStateWidget();
  }

  Widget buildPlayerStateWidget() {
    // double calcNormalizedProgress(Track? track, PlayerState? playerState) {
    //   if (track != null && playerState != null) {
    //     Log.log("Duration: ${track.duration}");
    //     Log.log("Position: ${playerState.playbackPosition}");
    //     final val = (1 / track.duration) * playerState.playbackPosition;
    //     Log.log("Progress: $val");
    //     return val;
    //   }
    //   return 0;
    // }

    final doMock = dotenv.getBool("MOCK_API", fallback: false);
    if (doMock) {
      final mockTrack = Track(
          Album("albumname", "uri"),
          Artist("artistname", "uri"),
          [Artist("artistname", "uri")],
          200,
          ImageUri("asd"),
          "track",
          "uri",
          null,
          isEpisode: false,
          isPodcast: false);

      return LowerPlayer(
          currentTrackImageUri: ImageUri("asd"),
          track: mockTrack,
          playerState: PlayerState(
              mockTrack,
              1.0,
              1,
              playOptions.PlayerOptions(playOptions.RepeatMode.off,
                  isShuffling: false),
              PlayerRestrictions(
                  canSkipNext: false,
                  canSkipPrevious: false,
                  canRepeatTrack: false,
                  canRepeatContext: false,
                  canToggleShuffle: false,
                  canSeek: false),
              isPaused: true));
    }

    late ImageUri? currentTrackImageUri;
    return StreamBuilder<PlayerState>(
        stream: SpotifySdk.subscribePlayerState(),
        builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
          var track = snapshot.data?.track;
          currentTrackImageUri = track?.imageUri;
          var playerState = snapshot.data;

          if (playerState == null || track == null) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              height: 100,
            );
          }

          // Update queue
          ref.read(queueProvider.notifier).refreshQueue();

          return LowerPlayer(
              currentTrackImageUri: currentTrackImageUri,
              track: track,
              playerState: playerState);
        });
  }
}

class LowerPlayer extends ConsumerWidget {
  const LowerPlayer({
    super.key,
    required this.currentTrackImageUri,
    required this.track,
    required this.playerState,
  });

  final ImageUri? currentTrackImageUri;
  final Track track;
  final PlayerState playerState;

  String getAllArtistNames(List<Artist> artists) {
    List<String?> artistsNames = [];
    for (final artist in artists) {
      artistsNames.add(artist.name);
    }
    var out = artistsNames.join(",");
    return out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminDisabled = ref.watch(isAdminDisabledProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 10,
        children: [
          Image.network(
            currentTrackImageUri!.raw,
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
          // Name and Progress
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ' ${track.name} - ${getAllArtistNames(track.artists)}', // Replace with dynamic title
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                LinearProgressIndicator(
                    // value: calcNormalizedProgress(track, playerState),
                    value: 0.5),
              ],
            ),
          ),

          // Play/Pause Button
          IconButton(
              color: Theme.of(context).colorScheme.onSurface,
              icon: Icon(playerState.isPaused ? Icons.play_arrow : Icons.pause),
              // icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () async {
                playerState.isPaused
                    ? await SpotifySdk.resume()
                    : await SpotifySdk.pause();
              }),
          IconButton(
            color: Theme.of(context).colorScheme.onSurface,
            icon: Icon(Icons.skip_next),
            onPressed: isAdminDisabled
                ? null
                : () async {
                    await SpotifySdk.skipNext();
                  },
          ),
        ],
      ),
    );
  }
}
