import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/widgets/artists_grid.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  final api = await SpotifyApiService.api;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Jukebox'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String token = "";

  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter() async {
    // await connectToSpotifyRemote();
    setState(() {
      _counter++;
    });
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      token = await getAccessToken();
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: "240ac9748340493fb136500a0e3acd95",
          redirectUrl: "http://localhost:44344/",
          playerName: "Small Player",
          accessToken: token);

      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> deleteToken() async {}

  Future<String> getAccessToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: "240ac9748340493fb136500a0e3acd95",
        redirectUrl: "http://localhost:44344/",
        scope:
            'streaming, user-read-playback-state, user-modify-playback-state, user-read-currently-playing, user-read-email, user-read-private',
      );
      setStatus('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  Future<Uint8List> getImage() async {
    // Future<void> getImage() async {
    final api = await SpotifyApiService.api;
    final url = await api.getArtistImageURL("2n2RSaZqBuUUukhbLlpnE6");
    final img = await api.getImage(url);
    return img;
  }

  Future<void> play() async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:track:0hKjGGWCAthLTNAbO5drvs');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> pause() async {
    await getImage();
    // return;
    // try {
    //   await SpotifySdk.pause();
    // } on PlatformException catch (e) {
    //   setStatus(e.code, message: e.message);
    // } on MissingPluginException {
    //   setStatus('not implemented');
    // }
  }

  Future<void> logout() async {
    var result = await SpotifySdk.disconnect();
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
    // print('$code$text');
  }

  refresh() {
    setState(() {});
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
            Expanded(child: ArtistsGridScreen()),
            Row(
              children: [
                FloatingActionButton.extended(
                  label: Text('play'),
                  // onPressed: play,
                  onPressed: refresh,
                  tooltip: 'connect',
                  icon: const Icon(Icons.playlist_play),
                ),
                FloatingActionButton.extended(
                  label: Text('resume'),
                  onPressed: resume,
                  tooltip: 'connect',
                  icon: const Icon(Icons.restaurant_menu),
                ),
                FloatingActionButton.extended(
                  label: Text('get image'),
                  onPressed: pause,
                  icon: const Icon(Icons.image),
                ),
                FloatingActionButton.extended(
                  label: Text('logout'),
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                ),
                FloatingActionButton.extended(
                  label: Text('delete'),
                  onPressed: deleteToken,
                  icon: const Icon(Icons.delete),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('connect'),
        onPressed: _incrementCounter,
        tooltip: 'connect',
        icon: const Icon(Icons.connect_without_contact),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
