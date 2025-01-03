// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbumCard _$AlbumCardFromJson(Map json) => AlbumCard(
      name: json['name'] as String,
      images: json['images'] as List<dynamic>?,
      id: json['id'] as String,
      artistName: json['artistName'] as String,
      popularity: (json['popularity'] as num).toInt(),
    );

Map<String, dynamic> _$AlbumCardToJson(AlbumCard instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'images': instance.images,
      'popularity': instance.popularity,
      'artistName': instance.artistName,
    };
