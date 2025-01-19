import 'package:json_annotation/json_annotation.dart';

part 'spotifyuser.g.dart';

@JsonSerializable()
class SpotifyUser {
  final String id;
  @JsonKey(name: "display_name")
  final String displayName;
  // Add other relevant data like title, description, etc.
  SpotifyUser({
    required this.id,
    required this.displayName,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) =>
      _$SpotifyUserFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyUserToJson(this);
}
