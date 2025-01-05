// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleTrack _$SimpleTrackFromJson(Map<String, dynamic> json) => SimpleTrack(
      name: json['name'] as String,
      images: json['images'] as List<dynamic>?,
      id: json['id'] as String,
      durationMs: (json['duration_ms'] as num).toInt(),
      allArtists: (json['artists'] as List<dynamic>)
          .map((e) => TrackArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
      album: TrackAlbum.fromJson(json['album'] as Map<String, dynamic>),
      uri: json['uri'] as String,
    );

Map<String, dynamic> _$SimpleTrackToJson(SimpleTrack instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'images': instance.images,
      'artists': instance.allArtists.map((e) => e.toJson()).toList(),
      'album': instance.album.toJson(),
      'duration_ms': instance.durationMs,
      'uri': instance.uri,
    };

TrackArtist _$TrackArtistFromJson(Map<String, dynamic> json) => TrackArtist(
      name: json['name'] as String,
    );

Map<String, dynamic> _$TrackArtistToJson(TrackArtist instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

TrackAlbum _$TrackAlbumFromJson(Map<String, dynamic> json) => TrackAlbum(
      name: json['name'] as String,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => SimpleImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrackAlbumToJson(TrackAlbum instance) =>
    <String, dynamic>{
      'name': instance.name,
      'images': instance.images?.map((e) => e.toJson()).toList(),
    };
