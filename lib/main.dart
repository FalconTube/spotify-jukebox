import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/api/spotify_sdk.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/states/artist_images_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_filters.dart';
import 'package:jukebox_spotify_flutter/states/loading_state.dart';
import 'package:jukebox_spotify_flutter/states/playlist_provider.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';
import 'package:jukebox_spotify_flutter/states/settings_provider.dart';
import 'package:jukebox_spotify_flutter/widgets/artist_grid.dart';
import 'package:jukebox_spotify_flutter/widgets/choice_chips.dart';
import 'package:jukebox_spotify_flutter/widgets/drawer.dart';
import 'package:jukebox_spotify_flutter/widgets/no_playlist_selected_placeholder.dart';
import 'package:jukebox_spotify_flutter/widgets/playlist_page.dart';
import 'package:jukebox_spotify_flutter/widgets/search.dart';
import 'package:jukebox_spotify_flutter/widgets/sidebar.dart';
import 'package:jukebox_spotify_flutter/widgets/virtual_keyboard.dart';
import 'package:jukebox_spotify_flutter/widgets/webplayer_bar.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

late ByteData placeholderRaw;
late Uint8List pl;
late bool spotifySdkEnabled;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init with env variables
  await dotenv.load(fileName: '.env');
  await SpotifyApiService.api;
  spotifySdkEnabled = dotenv.getBool('SPOTIFY_SDK_ENABLED', fallback: true);

  // Placeholder image for now
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
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Durations.extralong4,
      title: 'Jukebox',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.redAccent, brightness: Brightness.dark),
          // seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true),
      home: MyHomePage(title: 'Jukebox no Integration'),
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
  bool _sdkConnected = false;
  bool _playlistSelected = false;
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
      final debounceDelay = ref.watch(settingsProvider).debounceDelay.toInt();
      debounce = Timer(Duration(milliseconds: debounceDelay), () {
        // debounce = Timer(const Duration(milliseconds: 200), () {
        ref.read(searchQueryProvider.notifier).updateQuery(_controller.text);
        final genre = ref.read(chosenGenreFilterProvider);
        final requestType = ref.read(chosenSearchFilter);
        final searchResultAmount =
            ref.read(settingsProvider).searchResultAmount;
        ref.read(dataProvider.notifier).resetAndFetch(
            searchQuery: _controller.text,
            genre: genre,
            requestType: requestType,
            searchResultAmount: searchResultAmount);
        ref.read(isLoadingProvider.notifier).state = false;
      });
    });
  }

  @override
  void dispose() async {
    _controller.dispose();
    _searchFocusNode.dispose();
    await SpotifySdk.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaylistChosen = ref.watch(isPlaylistSelected);
    Log.log(isPlaylistChosen);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(widget.title),
          actions: [
            // Disconnect
            (spotifySdkEnabled && _sdkConnected)
                ? Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return PlaylistGridPage();
                            }));
                          },
                          icon: Icon(Icons.playlist_add_sharp)),
                      IconButton(
                          onPressed: () async {
                            await AllSDKFuncs.logout();
                            setState(() {
                              _sdkConnected = false;
                            });
                          },
                          icon: Icon(Icons.exit_to_app)),
                    ],
                  )
                : Container(),
            // Connect
          ],
        ),
        drawer: CustomDrawer(),
        bottomNavigationBar: (spotifySdkEnabled && _sdkConnected)
            ? WebPlayerBottomBar()
            : Text(""),
        body: switch (spotifySdkEnabled) {
          false => isPlaylistChosen
              ? MainWidget(
                  controller: _controller, searchFocusNode: _searchFocusNode)
              : NoPlaylistSelectedPlaceholder(),
          true => _sdkConnected
              ? isPlaylistChosen
                  ? MainWidget(
                      controller: _controller,
                      searchFocusNode: _searchFocusNode)
                  : NoPlaylistSelectedPlaceholder()
              : SpotifyLogin(context),
        });
  }

  Center SpotifyLogin(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 300,
        width: 300,
        child: Card(
          elevation: 5,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("spotify_logo_black.png", width: 80, height: 80),
              ElevatedButton(
                child: Text("Log in to Spotify Premium"),
                onPressed: () async {
                  await AllSDKFuncs.connectToSpotifyRemote();
                  setState(() {
                    _sdkConnected = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({
    super.key,
    required TextEditingController controller,
    required FocusNode searchFocusNode,
  })  : _controller = controller,
        _searchFocusNode = searchFocusNode;

  final TextEditingController _controller;
  final FocusNode _searchFocusNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MainCenter(controller: _controller, searchFocusNode: _searchFocusNode),
        SidebarPlayer(),
      ],
    );
  }
}

class MainCenter extends StatelessWidget {
  const MainCenter({
    super.key,
    required TextEditingController controller,
    required FocusNode searchFocusNode,
  })  : _controller = controller,
        _searchFocusNode = searchFocusNode;

  final TextEditingController _controller;
  final FocusNode _searchFocusNode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
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
                  Padding(padding: EdgeInsets.all(6)),
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
          // GenreFilter(),
          MyKeyboard(textcontroller: _controller, focusNode: _searchFocusNode),
        ]),
      ),
    );
  }
}
