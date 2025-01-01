import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_genre_filter.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';
import 'package:jukebox_spotify_flutter/widgets/artist_grid.dart';
import 'package:jukebox_spotify_flutter/widgets/genre_filter.dart';
import 'package:jukebox_spotify_flutter/widgets/search.dart';
import 'package:jukebox_spotify_flutter/widgets/virtual_keyboard.dart';

late ByteData placeholderRaw;
late Uint8List pl;
void main() async {
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
      title: 'Jukebox',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.dark),
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
  @override
  void initState() {
    super.initState();
    // Listen to changes in the text field and update the provider.
    _controller.addListener(() {
      if (_controller.text == compareValue) return;
      // Update comparison
      compareValue = _controller.text;
      // Update provider
      ref.read(searchQueryProvider.notifier).updateQuery(_controller.text);
      // Do API call
      final genre = ref.read(chosenGenreFilterProvider);
      ref
          .read(dataProvider.notifier)
          .resetAndFetch(searchQuery: _controller.text, genre: genre);
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MySearchbar(
                textcontroller: _controller, focusNode: _searchFocusNode),
            Expanded(
                child: Scaffold(
              body: ArtistGrid(placeholder: pl),
              floatingActionButton: FloatingActionButton.extended(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _controller.text = "";
                  },
                  label: Text("Clear Search")),
            )),
            GenreFilter(),
            MyKeyboard(
                textcontroller: _controller, focusNode: _searchFocusNode),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('connect'),
        onPressed: () {},
        tooltip: 'connect',
        icon: const Icon(Icons.connect_without_contact),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
