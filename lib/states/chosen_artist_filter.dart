import 'package:flutter_riverpod/flutter_riverpod.dart';

// A, B, C etc.
final chosenArtistFilterProvider = StateProvider<String>((ref) => 'A');

final chosenGenreFilterProvider = StateProvider<String>((ref) => '');
