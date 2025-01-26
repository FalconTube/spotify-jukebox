import 'package:json_annotation/json_annotation.dart';
import 'package:jukebox_spotify_flutter/classes/artist.dart';
import 'package:jukebox_spotify_flutter/classes/album.dart';
import 'package:jukebox_spotify_flutter/classes/playlist.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';

part 'response_data.g.dart';

@JsonSerializable(explicitToJson: true)
class ResponseData {
  // final List<ArtistCard>? artists;
  final ListArtistCards? artists;
  final ListAlbumCards? albums;
  final ListSimpleTracks? tracks;
  final ListPlaylists? playlists;
  // Add other relevant data like title, description, etc.
  ResponseData({
    required this.artists,
    required this.albums,
    required this.tracks,
    required this.playlists,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) =>
      _$ResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ListArtistCards {
  // @JsonKey(toJson: helptoJson, fromJson: helpfromJson)
  final List<ArtistCard> items;

  ListArtistCards({required this.items});

  factory ListArtistCards.fromJson(Map<String, dynamic> json) =>
      _$ListArtistCardsFromJson(json);
  //
  Map<String, dynamic> toJson() => _$ListArtistCardsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ListAlbumCards {
  // @JsonKey(toJson: helptoJson, fromJson: helpfromJson)
  final List<AlbumCard> items;

  ListAlbumCards({required this.items});

  factory ListAlbumCards.fromJson(Map<String, dynamic> json) =>
      _$ListAlbumCardsFromJson(json);
  //
  Map<String, dynamic> toJson() => _$ListAlbumCardsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ListSimpleTracks {
  // @JsonKey(toJson: helptoJson, fromJson: helpfromJson)
  final List<SimpleTrack> items;

  ListSimpleTracks({required this.items});

  factory ListSimpleTracks.fromJson(Map<String, dynamic> json) =>
      _$ListSimpleTracksFromJson(json);
  //
  Map<String, dynamic> toJson() => _$ListSimpleTracksToJson(this);
}

// @JsonSerializable(explicitToJson: true, includeIfNull: true)
@JsonSerializable(explicitToJson: true)
class ListPlaylists {
  // @JsonKey(toJson: helptoJson, fromJson: helpfromJson)
  final List<Playlist> items;

  ListPlaylists({required this.items});

  factory ListPlaylists.fromJson(Map<String, dynamic> json) {
    final data = json['items'] as List?;

    // json items inputs can be null, so handle that case
    final items = data
            ?.whereType<Map<String, dynamic>>()
            .map((item) => (item))
            .toList() ??
        [];
    return _$ListPlaylistsFromJson({'items': items});
  }
  //
  Map<String, dynamic> toJson() => _$ListPlaylistsToJson(this);
}
