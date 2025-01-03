import 'package:json_annotation/json_annotation.dart';

abstract class Info {
  final String name;
  final String id;
  final List<dynamic>? images;
  final int popularity;
  // Add other relevant data like title, description, etc.
  Info({
    required this.name,
    required this.id,
    required this.images,
    required this.popularity,
  });

  @override
  String toString() {
    return """
      Name: $name,
      ID: $id""";
  }

  String getImage() {
    if (images == null) return "";
    return images![0]["url"];
  }
}
