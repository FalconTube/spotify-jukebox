import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_filters.dart';
import 'package:jukebox_spotify_flutter/states/loading_state.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';
import 'package:jukebox_spotify_flutter/widgets/artist_grid.dart';
import 'package:jukebox_spotify_flutter/widgets/choice_chips.dart';
import 'package:jukebox_spotify_flutter/widgets/drawer.dart';
import 'package:jukebox_spotify_flutter/widgets/genre_filter.dart';
import 'package:jukebox_spotify_flutter/widgets/search.dart';
import 'package:jukebox_spotify_flutter/widgets/virtual_keyboard.dart';

late ByteData placeholderRaw;
late Uint8List pl;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SpotifyApiService.api;

  placeholderRaw = await rootBundle.load('favicon.png');
  pl = Uint8List.view(placeholderRaw.buffer);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeAnimationDuration: Durations.extralong4,
      title: 'Jukebox',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.redAccent, brightness: Brightness.dark),
          // seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true),
      home: MyHomePage(title: 'Jukebox'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController(text: "");
  final FocusNode _searchFocusNode = FocusNode();
  String compareValue = "";
  Timer? debounce;
  @override
  void initState() {
    super.initState();
    // Listen to changes in the text field and update the provider.
    _controller.addListener(() {
      if (_controller.text == compareValue) return;
      ref.read(isLoadingProvider.notifier).state = true;

      compareValue = _controller.text;
      // Update provider
      // Check if another call is in flight
      if (debounce?.isActive ?? false) debounce?.cancel();
      // API with debounce
      debounce = Timer(const Duration(milliseconds: 1500), () {
        ref.read(searchQueryProvider.notifier).updateQuery(_controller.text);
        final genre = ref.read(chosenGenreFilterProvider);
        final requestType = ref.read(chosenSearchFilter);
        ref.read(dataProvider.notifier).resetAndFetch(
            searchQuery: _controller.text,
            genre: genre,
            requestType: requestType);
        ref.read(isLoadingProvider.notifier).state = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 700) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChipRow(),
                  MySearchbar(
                    textcontroller: _controller,
                    focusNode: _searchFocusNode,
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChipRow(),
                  MySearchbar(
                    textcontroller: _controller,
                    focusNode: _searchFocusNode,
                  ),
                ],
              );
            }
          }),
          Expanded(
            child: ArtistGrid(placeholder: pl),
          ),
          GenreFilter(),
          MyKeyboard(textcontroller: _controller, focusNode: _searchFocusNode),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'f2',
        label: Text('connect'),
        onPressed: () {},
        tooltip: 'connect',
        icon: const Icon(Icons.connect_without_contact),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
