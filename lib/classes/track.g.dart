// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleTrack _$SimpleTrackFromJson(Map<String, dynamic> json) => SimpleTrack(
      name: json['type'] as String,
      imageUrl: json['imageUrl'] as String,
      id: json['id'] as String,
      popularity: (json['popularity'] as num).toInt(),
      durationMs: (json['durationMs'] as num).toInt(),
      artistName: json['artistName'] as String,
      albumName: json['albumName'] as String,
    );

Map<String, dynamic> _$SimpleTrackToJson(SimpleTrack instance) =>
    <String, dynamic>{
      'type': instance.name,
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'popularity': instance.popularity,
      'artistName': instance.artistName,
      'albumName': instance.albumName,
      'durationMs': instance.durationMs,
    };
