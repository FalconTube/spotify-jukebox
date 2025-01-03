// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbumCard _$AlbumCardFromJson(Map<String, dynamic> json) => AlbumCard(
      name: json['type'] as String,
      imageUrl: json['imageUrl'] as String,
      id: json['id'] as String,
      artistName: json['artistName'] as String,
      popularity: (json['popularity'] as num).toInt(),
    );

Map<String, dynamic> _$AlbumCardToJson(AlbumCard instance) => <String, dynamic>{
      'type': instance.name,
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'popularity': instance.popularity,
      'artistName': instance.artistName,
    };
