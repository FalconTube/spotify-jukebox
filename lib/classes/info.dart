// 1. Define your data model (if applicable)
import 'package:jukebox_spotify_flutter/types/request_type.dart';

class Info {
  final String name;
  final String id;
  final String imageUrl;
  final int popularity;
  final RequestType type;
  // Add other relevant data like title, description, etc.
  Info({
    required this.name,
    required this.id,
    required this.imageUrl,
    required this.popularity,
    required this.type,
  });

  @override
  String toString() {
    return """
      Name: $name,
      Img: $imageUrl,
      ID: $id""";
  }
}
