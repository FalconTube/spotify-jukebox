import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/types/request_type.dart';

final chosenGenreFilterProvider = StateProvider<String>((ref) => '');

final chosenSearchFilter =
    StateProvider<List<RequestType>>((ref) => [RequestType.artist]);
