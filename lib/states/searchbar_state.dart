import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super(''); // Initial state is an empty string.

  void updateQuery(String newQuery) {
    state = newQuery;
  }

  void clearQuery() {
    state = '';
  }
}

final searchQueryProvider =
    StateNotifierProvider<SearchQueryNotifier, String>((ref) {
  return SearchQueryNotifier();
});
