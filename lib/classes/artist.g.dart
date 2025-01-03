// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtistCard _$ArtistCardFromJson(Map json) => ArtistCard(
      name: json['name'] as String,
      images: json['images'] as List<dynamic>?,
      id: json['id'] as String,
      popularity: (json['popularity'] as num).toInt(),
      genres: json['genres'] as List<dynamic>?,
    );

Map<String, dynamic> _$ArtistCardToJson(ArtistCard instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'images': instance.images,
      'popularity': instance.popularity,
      'genres': instance.genres,
    };
