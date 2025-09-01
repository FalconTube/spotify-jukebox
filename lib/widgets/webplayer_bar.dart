import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/states/admin_enabled_provider.dart';
import 'package:jukebox_spotify_flutter/states/queue_provider.dart';
import 'package:jukebox_spotify_flutter/states/track_duration_provider.dart';
import 'package:spotify_sdk/models/album.dart';
import 'package:spotify_sdk/models/artist.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_options.dart' as playOptions;
import 'package:spotify_sdk/models/player_restrictions.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

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
          ref.read(trackDurationProvider.notifier).getTrackDuration(track.uri);

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
                AnimatedProgress(
                  track: track,
                  currentPosition: playerState.playbackPosition,
                )
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

class AnimatedProgress extends ConsumerStatefulWidget {
  const AnimatedProgress({
    super.key,
    required this.track,
    required this.currentPosition,
  });

  final Track track;
  final int currentPosition;

  @override
  ConsumerState<AnimatedProgress> createState() => _AnimatedProgressState();
}

class _AnimatedProgressState extends ConsumerState<AnimatedProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween<double> _tween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant AnimatedProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPosition != widget.currentPosition) {
      final trackDuration = ref.read(trackDurationProvider);
      final currentProgress =
          calcNormalizedProgress(trackDuration, widget.currentPosition);

      int remainingDuration = trackDuration - widget.currentPosition;
      if (remainingDuration < 0) {
        remainingDuration = 60000;
      }

      _tween = Tween<double>(begin: currentProgress, end: 1.0);
      _controller
        ..duration = Duration(milliseconds: remainingDuration)
        ..forward(from: 0.0); // Restart the animation
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _tween.evaluate(_controller);
        return LinearProgressIndicator(value: value);
      },
    );
  }
}

// class AnimatedProgress extends ConsumerStatefulWidget {
//   const AnimatedProgress({
//     super.key,
//     required this.track,
//     required this.currentPosition,
//   });

//   final Track track;
//   final int currentPosition;

//   @override
//   ConsumerState<AnimatedProgress> createState() => _AnimatedProgressState();
// }

// class _AnimatedProgressState extends ConsumerState<AnimatedProgress> {
//   @override
//   Widget build(BuildContext context) {
//     final trackDuration = ref.watch(trackDurationProvider);

//     int remainingDuration = trackDuration - widget.currentPosition;
//     if (remainingDuration < 0) {
//       remainingDuration = 180000;
//     }
//     final currentProgress =
//         calcNormalizedProgress(trackDuration, widget.currentPosition);
//     return TweenAnimationBuilder<double>(
//       key: ValueKey(remainingDuration),
//       duration: Duration(milliseconds: remainingDuration),
//       tween: Tween<double>(begin: currentProgress, end: 1.0),
//       curve: Curves.linear,
//       builder: (BuildContext context, double value, _) {
//         return LinearProgressIndicator(value: value);
//       },
//     );
//   }
// }

double calcNormalizedProgress(int trackDuration, int progress) {
  if (trackDuration != 0 && progress != 0) {
    final val = (1 / trackDuration) * progress;
    return val;
  }
  return 0;
}
