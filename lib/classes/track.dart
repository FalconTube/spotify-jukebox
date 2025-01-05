import 'package:json_annotation/json_annotation.dart';
import 'package:jukebox_spotify_flutter/classes/info.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/image.dart';
import 'package:jukebox_spotify_flutter/classes/album.dart';

part 'track.g.dart';

@JsonSerializable(explicitToJson: true, createToJson: true, createFactory: true)
class SimpleTrack extends Info {
  @JsonKey(name: "artists")
  final List<TrackArtist> allArtists;
  final TrackAlbum album;
  @JsonKey(name: "duration_ms")
  final int durationMs;
  final String uri;
  // Add other relevant data like title, description, etc.
  SimpleTrack({
    required super.name,
    required super.images,
    required super.id,
    required this.durationMs,
    required this.allArtists,
    required this.album,
    required this.uri,
  });

  factory SimpleTrack.fromJson(Map<String, dynamic> json) =>
      _$SimpleTrackFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleTrackToJson(this);

  String prettyDuration() {
    int durationSec = (durationMs / 1000).toInt();
    int remainSec = durationSec % 60;
    int remainMin = ((durationSec - remainSec) / 60).toInt();
    String paddedSec = remainSec.toString().padLeft(2, "0");

    return "$remainMin : $paddedSec";
  }

  @override
  String getImage() {
    if (album.images == null) return "";
    return album.images![0].url;
  }

  String mainArtist() {
    return allArtists[0].name;
  }

  String albumName() {
    return album.name;
  }
}

@JsonSerializable(explicitToJson: true, createToJson: true, createFactory: true)
class TrackArtist {
  String name;

  TrackArtist({required this.name});
  Map<String, dynamic> toJson() => _$TrackArtistToJson(this);

  factory TrackArtist.fromJson(Map<String, dynamic> json) =>
      _$TrackArtistFromJson(json);
}

@JsonSerializable(explicitToJson: true, createToJson: true, createFactory: true)
class TrackAlbum {
  String name;
  List<SimpleImage>? images;

  TrackAlbum({required this.name, required this.images});
  Map<String, dynamic> toJson() => _$TrackAlbumToJson(this);

  factory TrackAlbum.fromJson(Map<String, dynamic> json) =>
      _$TrackAlbumFromJson(json);
}
