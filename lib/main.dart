import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:jukebox_spotify_flutter/widgets/detail_view.dart';
import 'package:jukebox_spotify_flutter/widgets/drawer.dart';
import 'package:jukebox_spotify_flutter/widgets/no_playlist_selected_placeholder.dart';
import 'package:jukebox_spotify_flutter/widgets/playlist_page.dart';
import 'package:jukebox_spotify_flutter/widgets/search.dart';
import 'package:jukebox_spotify_flutter/widgets/sidebar.dart';
import 'package:jukebox_spotify_flutter/widgets/webplayer_bar.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'package:pinput/pinput.dart';

late ByteData placeholderRaw;
late Uint8List pl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init with env variables
  await dotenv.load(fileName: '.env');
  await SpotifyApiService.api;

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
  final GoRouter router = GoRouter(routes: [
    ShellRoute(
        builder: (context, state, child) {
          final primary = Theme.of(context).colorScheme.primaryContainer;
          final surface = Theme.of(context).colorScheme.surface;
          final theme = OnscreenKeyboardThemeData(
            color: Color.lerp(primary, surface, 0.8),
            controlBarColor: Color.lerp(primary, surface, 0.8),
            padding:
                const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 14),
            boxShadow: [],
            border: const Border.fromBorderSide(BorderSide.none),
            borderRadius: BorderRadius.zero,
            textKeyThemeData: TextKeyThemeData(
              backgroundColor: surface,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              borderRadius: BorderRadius.circular(6),
            ),
            actionKeyThemeData: ActionKeyThemeData(
              backgroundColor: Color.lerp(primary, surface, 0.5),
              pressedBackgroundColor: primary,
              margin: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 4,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          );
          return OnscreenKeyboard(
              aspectRatio: 32.0 / 9.0,
              layout: DesktopKeyboardLayout(),
              theme: theme,
              child: MyHomePage(body: child));
        },
        routes: [
          GoRoute(
            path: "/main",
            builder: (context, state) => MainWrapper(),
          ),
          GoRoute(
            path: "/detail",
            builder: (context, state) => DetailView(),
          ),
          GoRoute(
            path: "/playlists",
            builder: (context, state) => PlaylistGridPage(),
          )
        ])
  ], initialLocation: "/main");
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
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
      routerConfig: router,
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.body});
  final Widget body;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController pinController = TextEditingController();
  final title = "Spotify Jukebox";

  @override
  Widget build(BuildContext context) {
    final sdkConnected = ref.watch(isSdkConnected);
    final doMock = dotenv.getBool("MOCK_API", fallback: false);
    final isAdminDisabled = ref.watch(isAdminDisabledProvider);
    final adminPin = ref.watch(settingsProvider).adminPin;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(title,
            style: TextStyle(
              // fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            )),
        // leading: DrawerButton(),
        actions: [
          // Disconnect
          (sdkConnected || doMock)
              ? Row(
                  children: [
                    IconButton(
                        color: Theme.of(context).colorScheme.onSurface,
                        onPressed: isAdminDisabled
                            ? null
                            : () {
                                GoRouter.of(context).go("/playlists");
                              },
                        icon: Icon(Icons.playlist_add_sharp)),
                    IconButton(
                        color: Theme.of(context).colorScheme.onSurface,
                        onPressed: () {
                          Log.log("Admin pin is: $adminPin");
                          if (isAdminDisabled == true) {
                            _showPinInputDialog(context, adminPin, ref);
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
      bottomNavigationBar: WebPlayerBottomBar(),
      // body: MainWrapper(),
      body: widget.body,
    );
  }

  void _showPinInputDialog(
      BuildContext context, String adminPin, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter admin code'),
          content: SizedBox(
            height: 200,
            child: Pinput(
              controller: pinController,
              length: 4,
              autofocus: true,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              keyboardType: TextInputType.number,
              onCompleted: (pin) {
                if (pin == adminPin) {
                  pinController.clear();
                  ref.read(isAdminDisabledProvider.notifier).state = false;
                  Navigator.of(dialogContext).pop();
                } else {
                  setState(() {
                    pinController.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect code!')),
                  );
                }
              },
            ),
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
    return Scaffold(
      body: Row(
        children: [
          SearchAndGrid(
              controller: controller,
              searchFocusNode: searchFocusNode,
              gridWidget: artistGrid),
          SidebarPlayer(),
        ],
      ),
    );
  }
}

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  final TextEditingController controller = TextEditingController(text: "");
  final FocusNode searchFocusNode = FocusNode();

  late final keyboard = OnscreenKeyboard.of(context);

  void _listener(OnscreenKeyboardKey key) {
    switch (key) {
      case TextKey(:final primary): // a text key: "a", "b", "4", etc.
        print('key: "$primary"');
      case ActionKey(:final name): // an action key: "shift", "backspace", etc.
        print('action: $name');
    }
  }

  Timer? debounce;
  @override
  void initState() {
    final searchText = ref.read(searchQueryProvider);
    controller.text = searchText;
    super.initState();
    keyboard.addRawKeyDownListener(_listener);
    // Listen to changes in the text field and update the provider.
    controller.addListener(() {
      if (controller.text == searchText) return;
      ref.read(isLoadingProvider.notifier).state = true;

      // Update provider
      // Check if another call is in flight
      if (debounce?.isActive ?? false) debounce?.cancel();
      // API with debounce
      final debounceDelay = ref.watch(settingsProvider).debounceDelay.toInt();
      debounce = Timer(Duration(milliseconds: debounceDelay), () {
        ref.read(isSpeechListening.notifier).state = false;
        ref.read(searchQueryProvider.notifier).updateQuery(controller.text);
        final genre = ref.read(chosenGenreFilterProvider);
        final requestType = ref.read(chosenSearchFilter);
        final searchResultAmount =
            ref.read(settingsProvider).searchResultAmount;
        ref.read(dataProvider.notifier).resetAndFetch(
            searchQuery: controller.text,
            genre: genre,
            requestType: requestType,
            searchResultAmount: searchResultAmount);
        ref.read(isLoadingProvider.notifier).state = false;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    searchFocusNode.dispose();
    keyboard.removeRawKeyDownListener(_listener);
    // await SpotifySdk.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sdkConnected = ref.watch(isSdkConnected);
    final isPlaylistChosen = ref.watch(isPlaylistSelected);
    final doMock = dotenv.getBool("MOCK_API", fallback: false);

    return (sdkConnected || doMock)
        ? isPlaylistChosen
            ? MainWidget(
                controller: controller, searchFocusNode: searchFocusNode)
            : NoPlaylistSelectedPlaceholder()
        : SpotifyLogin();
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
                  padding: const EdgeInsets.all(30.0),
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
          // MyKeyboard(textcontroller: controller, focusNode: searchFocusNode),
        ]),
      ),
    );
  }
}

class SpotifyLogin extends ConsumerWidget {
  const SpotifyLogin({super.key});

  @override
  Widget build(BuildContext context, ref) {
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
                          'app-remote-control, streaming, user-read-playback-state, user-modify-playback-state, user-read-currently-playing, user-read-email, user-read-private, playlist-read-private, playlist-read-collaborative, user-top-read',
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
}
