import 'package:jukebox_spotify_flutter/classes/info.dart';

class AlbumCard extends Info {
  final String artistName;
  // Add other relevant data like title, description, etc.
  AlbumCard({
    required super.name,
    required super.imageUrl,
    required super.id,
    required super.type,
    required this.artistName,
    required super.popularity,
  });
}
