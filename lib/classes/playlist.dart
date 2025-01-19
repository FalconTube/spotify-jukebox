import 'package:json_annotation/json_annotation.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';

part 'playlist.g.dart';

@JsonSerializable()
class Playlist extends Info {
  // Add other relevant data like title, description, etc.
  Playlist({
    required super.name,
    required super.images,
    required super.id,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}
