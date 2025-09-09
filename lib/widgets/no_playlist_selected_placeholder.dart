import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/states/playlist_provider.dart';
import 'package:jukebox_spotify_flutter/widgets/playlist_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';

class NoPlaylistSelectedPlaceholder extends ConsumerWidget {
  const NoPlaylistSelectedPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectCard(
              icon: Icons.playlist_add_sharp,
              text: "Select fallback playlist",
              function: () {
                GoRouter.of(context).go("/playlists");
              }),
          SelectCard(
              icon: Icons.skip_previous_outlined,
              text: "Continue without playlist",
              function: () async {
                final api = await SpotifyApiService.api;
                final topTrackUser = await api.getTopTrack();
                await SpotifySdk.queue(spotifyUri: topTrackUser);
                Future.delayed(Duration(milliseconds: 200));
                await SpotifySdk.resume();
                Future.delayed(Duration(milliseconds: 200));
                await SpotifySdk.pause();
                ref.read(isPlaylistSelected.notifier).state = true;
              }),
        ],
      ),
    );
  }
}

class SelectCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function() function;

  const SelectCard({
    super.key,
    required this.icon,
    required this.text,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Add a subtle shadow
      margin: const EdgeInsets.all(16), // Add some margin around the card
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: function,
        child: Padding(
          padding: const EdgeInsets.all(24), // Add padding inside the card
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Important: Use min to avoid stretching
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              Icon(
                icon,
                size: 64, // Make the icon larger
                color: Theme.of(context).colorScheme.onSurface,
              ),
              Text(
                text,
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
