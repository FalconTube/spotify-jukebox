import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/states/admin_enabled_provider.dart';
import 'package:jukebox_spotify_flutter/states/data_query_provider.dart';
import 'package:jukebox_spotify_flutter/states/chosen_filters.dart';
import 'package:jukebox_spotify_flutter/states/loading_state.dart';
import 'package:jukebox_spotify_flutter/states/playlist_provider.dart';
import 'package:jukebox_spotify_flutter/states/sdk_connected_provider.dart';
import 'package:jukebox_spotify_flutter/states/searchbar_state.dart';
import 'package:jukebox_spotify_flutter/states/settings_provider.dart';
import 'package:jukebox_spotify_flutter/states/sidebar_visible_provider.dart';
import 'package:jukebox_spotify_flutter/states/speech_listening_provider.dart';
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

import 'package:pinput/pinput.dart';

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
  placeholderRaw = await rootBundle.load('assets/placeholder.png');
  pl = Uint8List.view(placeholderRaw.buffer);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Durations.short3,
      title: 'Jukebox',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            dynamicSchemeVariant: settings.vibrantColors
                ? DynamicSchemeVariant.vibrant
                : DynamicSchemeVariant.rainbow,
            seedColor: settings.seedColor,
            brightness: settings.brightness,
          ),
          useMaterial3: true),
      home: MyHomePage(title: 'Spotify Jukebox'),
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
  final TextEditingController _pinController = TextEditingController();
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
        ref.read(isSpeechListening.notifier).state = false;
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
    final _sdkConnected = ref.watch(isSdkConnected);
    final doMock = dotenv.getBool("MOCK_API", fallback: false);
    final isPlaylistChosen = ref.watch(isPlaylistSelected);
    final isAdminDisabled = ref.watch(isAdminDisabledProvider);
    final adminPin = ref.watch(settingsProvider).adminPin;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(widget.title,
              style: TextStyle(
                // fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              )),
          // leading: DrawerButton(),
          actions: [
            // Disconnect
            (_sdkConnected || doMock)
                ? Row(
                    children: [
                      IconButton(
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: isAdminDisabled
                              ? null
                              : () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return PlaylistGridPage();
                                  }));
                                },
                          icon: Icon(Icons.playlist_add_sharp)),
                      IconButton(
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: () {
                            Log.log("Admin pin is: $adminPin");
                            if (isAdminDisabled == true) {
                              _showPinInputDialog(context, adminPin);
                              return;
                            }
                            // Invert visibilty
                            ref.read(isAdminDisabledProvider.notifier).state =
                                !isAdminDisabled;
                          },
                          icon: isAdminDisabled
                              ? Icon(Icons.lock_open)
                              : Icon(Icons.lock)),
                    ],
                  )
                : Container(),
          ],
        ),
        drawer: isAdminDisabled ? null : CustomDrawer(),
        bottomNavigationBar:
            (_sdkConnected) ? WebPlayerBottomBar() : WebPlayerBottomBar(),
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
              Image.asset("assets/spotify_logo_black.png",
                  width: 80, height: 80),
              ElevatedButton(
                child: Text("Log in to Spotify Premium"),
                onPressed: () async {
                  try {
                    String clientId = dotenv.env['CLIENT_ID'].toString();
                    String redirectUrl = dotenv.env['REDIRECT_URL'].toString();
                    await SpotifySdk.connectToSpotifyRemote(
                      clientId: clientId,
                      redirectUrl: redirectUrl,
                      playerName: "Jukebox",
                      scope:
                          'app-remote-control, streaming, user-read-playback-state, user-modify-playback-state, user-read-currently-playing, user-read-email, user-read-private, playlist-read-private, playlist-read-collaborative',
                    );
                    await SpotifySdk.getPlayerState();
                  } catch (e) {
                    Log.log("Not connected to Spotify. Error $e");
                    return;
                  }
                  ref.read(isSdkConnected.notifier).update((state) => true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinInputDialog(BuildContext context, String adminPin) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter admin code'),
          content: Pinput(
            controller: _pinController,
            length: 4,
            autofocus: true,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            keyboardType: TextInputType.number,
            onCompleted: (pin) {
              if (pin == adminPin) {
                _pinController.clear();
                ref.read(isAdminDisabledProvider.notifier).state = false;
                Navigator.of(dialogContext).pop();
              } else {
                setState(() {
                  _pinController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect code!')),
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DrawerButton extends StatelessWidget {
  const DrawerButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: Icon(Icons.settings));
  }
}

class MainWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode searchFocusNode;
  MainWidget({
    super.key,
    required this.controller,
    required this.searchFocusNode,
  });

  final artistGrid = ArtistGrid(placeholder: pl);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SearchAndGrid(
            controller: controller,
            searchFocusNode: searchFocusNode,
            gridWidget: artistGrid),
        SidebarPlayer(),
      ],
    );
  }
}

class SearchAndGrid extends StatelessWidget {
  final Widget gridWidget;
  final TextEditingController controller;
  final FocusNode searchFocusNode;

  const SearchAndGrid(
      {super.key,
      required this.controller,
      required this.searchFocusNode,
      required this.gridWidget});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            // if (constraints.maxWidth > 800) {
            return Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ChipRow(),
                ),
                MySearchbar(
                  textcontroller: controller,
                  focusNode: searchFocusNode,
                ),
              ],
            );
          }),
          Expanded(child: gridWidget),
          // GenreFilter(),
          MyKeyboard(textcontroller: controller, focusNode: searchFocusNode),
        ]),
      ),
    );
  }
}
