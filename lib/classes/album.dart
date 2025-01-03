import 'package:json_annotation/json_annotation.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';

part 'album.g.dart';

@JsonSerializable()
class AlbumCard extends Info {
  final String artistName;
  // Add other relevant data like title, description, etc.
  AlbumCard({
    required super.name,
    required super.images,
    required super.id,
    required this.artistName,
    required super.popularity,
  });

  factory AlbumCard.fromJson(Map<String, dynamic> json) =>
      _$AlbumCardFromJson(json);

  Map<String, dynamic> toJson() => _$AlbumCardToJson(this);
}
