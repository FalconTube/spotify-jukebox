import 'package:flutter/material.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/api/spotify_sdk.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class WebPlayerBottomBar extends StatefulWidget {
  const WebPlayerBottomBar({super.key});

  @override
  WebPlayerBottomBarState createState() => WebPlayerBottomBarState();
}

class WebPlayerBottomBarState extends State<WebPlayerBottomBar> {
  double _progressValue = 0.5; // Initial progress
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 10,
        children: [
          // Image
          Image.asset('favicon.png', // Replace with your image URL
              width: 40,
              height: 40,
              fit: BoxFit.cover),
          // Name and Progress
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Song Title - Song Artist', // Replace with dynamic title
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 8.0),
                  ),
                  child: Slider(
                    value: _progressValue,
                    onChanged: (value) {
                      setState(() async {
                        _progressValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Play/Pause Button
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () async {
              final pstate = await SpotifySdk.getPlayerState();
              setState(() {
                if (pstate?.isPaused == true) {
                  SpotifySdk.resume();
                  _isPlaying = true;
                } else {
                  SpotifySdk.pause();
                  _isPlaying = false;
                }
              });
            },
          ),
          // Next Button
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: () {
              SpotifySdk.skipNext();
              // Handle next action
            },
          ),
          // Next Button
          IconButton(
            icon: Icon(Icons.select_all_rounded),
            onPressed: () async {
              final api = await SpotifyApiService.api;
              await api.playOrSelectPlaylist("4fsfUApjaJvJIvjuC3qOJt",
                  selectOnly: true);
              // Handle next action
            },
          ),
        ],
      ),
    );
  }
}
