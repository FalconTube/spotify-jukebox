// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleTrack _$SimpleTrackFromJson(Map json) => SimpleTrack(
      name: json['name'] as String,
      images: json['images'] as List<dynamic>?,
      id: json['id'] as String,
      popularity: (json['popularity'] as num).toInt(),
      durationMs: (json['duration_ms'] as num).toInt(),
      allArtists: (json['artists'] as List<dynamic>)
          .map((e) => TrackArtist.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      album:
          TrackAlbum.fromJson(Map<String, dynamic>.from(json['album'] as Map)),
    );

Map<String, dynamic> _$SimpleTrackToJson(SimpleTrack instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'images': instance.images,
      'popularity': instance.popularity,
      'artists': instance.allArtists.map((e) => e.toJson()).toList(),
      'album': instance.album.toJson(),
      'duration_ms': instance.durationMs,
    };

TrackArtist _$TrackArtistFromJson(Map json) => TrackArtist(
      name: json['name'] as String,
    );

Map<String, dynamic> _$TrackArtistToJson(TrackArtist instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

TrackAlbum _$TrackAlbumFromJson(Map json) => TrackAlbum(
      name: json['name'] as String,
      images: (json['images'] as List<dynamic>?)
          ?.map(
              (e) => SimpleImage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$TrackAlbumToJson(TrackAlbum instance) =>
    <String, dynamic>{
      'name': instance.name,
      'images': instance.images?.map((e) => e.toJson()).toList(),
    };
