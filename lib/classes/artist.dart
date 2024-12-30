// 1. Define your data model (if applicable)
class ArtistCard {
  final String name;
  final int followers;
  final int popularity;
  final String imageUrl;
  // Add other relevant data like title, description, etc.
  ArtistCard({
    required this.name,
    required this.followers,
    required this.popularity,
    required this.imageUrl,
  });

  @override
  String toString() {
    return "Name: $name, Pop: $popularity, Fol: $followers Img: $imageUrl";
  }
}
