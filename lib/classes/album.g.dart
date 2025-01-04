// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbumCard _$AlbumCardFromJson(Map<String, dynamic> json) => AlbumCard(
      name: json['name'] as String,
      images: json['images'] as List<dynamic>?,
      id: json['id'] as String,
      artists: (json['artists'] as List<dynamic>)
          .map((e) => AlbumArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AlbumCardToJson(AlbumCard instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'images': instance.images,
      'artists': instance.artists,
    };

AlbumArtist _$AlbumArtistFromJson(Map<String, dynamic> json) => AlbumArtist(
      name: json['name'] as String,
    );

Map<String, dynamic> _$AlbumArtistToJson(AlbumArtist instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
