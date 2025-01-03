// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtistCard _$ArtistCardFromJson(Map<String, dynamic> json) => ArtistCard(
      name: json['type'] as String,
      imageUrl: json['imageUrl'] as String,
      id: json['id'] as String,
      popularity: (json['popularity'] as num).toInt(),
      genres: json['genres'] as String,
      followers: (json['followers'] as num).toInt(),
    );

Map<String, dynamic> _$ArtistCardToJson(ArtistCard instance) =>
    <String, dynamic>{
      'type': instance.name,
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'popularity': instance.popularity,
      'followers': instance.followers,
      'genres': instance.genres,
    };
