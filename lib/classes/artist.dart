import 'package:json_annotation/json_annotation.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';

part 'artist.g.dart';

@JsonSerializable()
class ArtistCard extends Info {
  final int followers;
  final String genres;
  // Add other relevant data like title, description, etc.
  ArtistCard({
    required super.name,
    required super.imageUrl,
    required super.id,
    required super.popularity,
    required this.genres,
    required this.followers,
  });

  factory ArtistCard.fromJson(Map<String, dynamic> json) =>
      _$ArtistCardFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistCardToJson(this);
}
