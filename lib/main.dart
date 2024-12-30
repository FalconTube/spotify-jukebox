import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';
import 'package:jukebox_spotify_flutter/widgets/artist_filter.dart';
import 'package:jukebox_spotify_flutter/widgets/artist_grid.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  await SpotifyApiService.api;
  runApp(ProviderScope(child: MyApp()));
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
  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> getImage() async {
    // Future<void> getImage() async {
    final api = await SpotifyApiService.api;
    final url = await api.getArtistImageURL("2n2RSaZqBuUUukhbLlpnE6");
    final img = await api.getImage(url);
    return img;
  }

  Future<void> doImage() async {
    await getImage();
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
            Expanded(child: ArtistGrid()),
            ArtistFilter(),
            Row(
              children: [
                FloatingActionButton.extended(
                  label: Text('get image'),
                  onPressed: doImage,
                  icon: const Icon(Icons.image),
                ),
              ],
            )
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
