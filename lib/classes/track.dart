import 'package:jukebox_spotify_flutter/classes/info.dart';

class SimpleTrack extends Info {
  final String artistName;
  final String albumName;
  final int durationMs;
  // Add other relevant data like title, description, etc.
  SimpleTrack({
    required super.name,
    required super.imageUrl,
    required super.id,
    required super.popularity,
    required super.type,
    required this.durationMs,
    required this.artistName,
    required this.albumName,
  });

  String prettyDuration() {
    int durationSec = (durationMs / 1000).toInt();
    int remainSec = durationSec % 60;
    int remainMin = ((durationSec - remainSec) / 60).toInt();
    String paddedSec = remainSec.toString().padLeft(2, "0");

    return "$remainMin : $paddedSec";
  }
}
