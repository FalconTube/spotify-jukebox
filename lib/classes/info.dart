import 'package:jukebox_spotify_flutter/classes/album.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/types/request_type.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'info.g.dart';

abstract class Info {
  @JsonKey(name: 'type')
  final String name;
  final String id;
  final String imageUrl;
  final int popularity;
  // Add other relevant data like title, description, etc.
  Info({
    required this.name,
    required this.id,
    required this.imageUrl,
    required this.popularity,
  });

  @override
  String toString() {
    return """
      Name: $name,
      Img: $imageUrl,
      ID: $id""";
  }
}
