// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseData _$ResponseDataFromJson(Map<String, dynamic> json) => ResponseData(
      artists: json['artists'] == null
          ? null
          : ListArtistCards.fromJson(json['artists'] as Map<String, dynamic>),
      albums: json['albums'] == null
          ? null
          : ListAlbumCards.fromJson(json['albums'] as Map<String, dynamic>),
      tracks: json['tracks'] == null
          ? null
          : ListSimpleTracks.fromJson(json['tracks'] as Map<String, dynamic>),
      playlists: json['playlists'] == null
          ? null
          : ListPlaylists.fromJson(json['playlists'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResponseDataToJson(ResponseData instance) =>
    <String, dynamic>{
      'artists': instance.artists?.toJson(),
      'albums': instance.albums?.toJson(),
      'tracks': instance.tracks?.toJson(),
      'playlists': instance.playlists?.toJson(),
    };

ListArtistCards _$ListArtistCardsFromJson(Map<String, dynamic> json) =>
    ListArtistCards(
      items: (json['items'] as List<dynamic>)
          .map((e) => ArtistCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListArtistCardsToJson(ListArtistCards instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

ListAlbumCards _$ListAlbumCardsFromJson(Map<String, dynamic> json) =>
    ListAlbumCards(
      items: (json['items'] as List<dynamic>)
          .map((e) => AlbumCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListAlbumCardsToJson(ListAlbumCards instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

ListSimpleTracks _$ListSimpleTracksFromJson(Map<String, dynamic> json) =>
    ListSimpleTracks(
      items: (json['items'] as List<dynamic>)
          .map((e) => SimpleTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListSimpleTracksToJson(ListSimpleTracks instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

ListPlaylists _$ListPlaylistsFromJson(Map<String, dynamic> json) =>
    ListPlaylists(
      items: (json['items'] as List<dynamic>)
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListPlaylistsToJson(ListPlaylists instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
