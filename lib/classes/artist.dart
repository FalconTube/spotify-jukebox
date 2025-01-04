import 'package:json_annotation/json_annotation.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';

part 'artist.g.dart';

@JsonSerializable(explicitToJson: true, createToJson: true, createFactory: true)
class ArtistCard extends Info {
  // @JsonKey(name: 'followers.total')
  // final int followers;
  final List<dynamic>? genres;
  final int popularity;
  // Add other relevant data like title, description, etc.
  ArtistCard({
    required super.name,
    required super.images,
    required super.id,
    required this.popularity,
    required this.genres,
    // required this.followers,
  });

  factory ArtistCard.fromJson(Map<String, dynamic> json) =>
      _$ArtistCardFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistCardToJson(this);
}

// @JsonSerializable()
// class Followers {
//   final int total;
// }
