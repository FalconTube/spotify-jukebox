import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/main.dart';
import 'package:jukebox_spotify_flutter/states/queue_provider.dart';

class SidebarPlayer extends ConsumerStatefulWidget {
  const SidebarPlayer({super.key});

  @override
  ConsumerState<SidebarPlayer> createState() => SidebarPlayerState();
}

class SidebarPlayerState extends ConsumerState<SidebarPlayer> {
  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(queueProvider);
    // If screen is size, use full width
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 700;
    final double sidebarWidth = isLargeScreen ? 400 : 80;
    return _Sidebar(
        queue: queue, sidebarWidth: sidebarWidth, isLargeScreen: isLargeScreen);
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.queue,
    required this.sidebarWidth,
    required this.isLargeScreen,
  });

  final List<SimpleTrack> queue;
  final double sidebarWidth;
  final bool isLargeScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sidebarWidth,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          Expanded(
            child: queue.isEmpty
                ? Container()
                : ListView.builder(
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final track = queue[index];
                      return isLargeScreen
                          ? ExpandedQueueItem(track: track, index: index)
                          : CollapsedQueueItem(track: track);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CollapsedQueueItem extends StatelessWidget {
  const CollapsedQueueItem({
    super.key,
    required this.track,
  });

  final SimpleTrack track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        key: ValueKey(track.uri),
        leading: track.getImage() != ""
            ? FadeInImage.memoryNetwork(
                fadeInDuration: const Duration(milliseconds: 300),
                image: track.getImage(),
                fit: BoxFit.cover,
                placeholder: pl)
            : Image.asset("assets/placeholder.png", fit: BoxFit.cover));
  }
}

class ExpandedQueueItem extends StatelessWidget {
  const ExpandedQueueItem(
      {super.key, required this.track, required this.index});

  final SimpleTrack track;
  final int index;
  static const Map<int, double> indexToSize = {0: 30.0, 1: 22.0, 2: 15.0};

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Padding(
            key: ValueKey(track.uri),
            padding: const EdgeInsets.all(2),
            child: InnerListTile(track: track, index: index)));
  }
}

class InnerListTile extends StatelessWidget {
  const InnerListTile({
    super.key,
    required this.track,
    required this.index,
  });

  final SimpleTrack track;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(track.name),
        subtitle: Text(track.mainArtist()),
        trailing: Text("${index + 1}."),
        leading: track.getImage() != ""
            ? FadeInImage.memoryNetwork(
                fadeInDuration: const Duration(milliseconds: 300),
                image: track.getImage(),
                fit: BoxFit.cover,
                placeholder: pl)
            : Image.asset("assets/placeholder.png", fit: BoxFit.cover));
  }
}
