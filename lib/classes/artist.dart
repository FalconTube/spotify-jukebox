import 'package:jukebox_spotify_flutter/classes/info.dart';

class ArtistCard extends Info {
  final int followers;
  final String genres;
  // Add other relevant data like title, description, etc.
  ArtistCard({
    required super.name,
    required super.imageUrl,
    required super.id,
    required super.popularity,
    required super.type,
    required this.genres,
    required this.followers,
  });

  factory ArtistCard.fromSuperclass(
      Info superInstance, String genres, int followers) {
    return ArtistCard(
      name: superInstance.name,
      imageUrl: superInstance.imageUrl,
      id: superInstance.id,
      popularity: superInstance.popularity,
      type: superInstance.type,
      genres: genres,
      followers: followers,
    );
  }
}
