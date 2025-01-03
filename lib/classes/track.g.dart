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
      durationMs: (json['durationMs'] as num).toInt(),
      artistName: json['artistName'] as String,
      albumName: json['albumName'] as String,
    );

Map<String, dynamic> _$SimpleTrackToJson(SimpleTrack instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'images': instance.images,
      'popularity': instance.popularity,
      'artistName': instance.artistName,
      'albumName': instance.albumName,
      'durationMs': instance.durationMs,
    };
