import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jukebox_spotify_flutter/api/spotify_api.dart';

class ArtistsGridScreen extends StatefulWidget {
  const ArtistsGridScreen({super.key});

  @override
  State<ArtistsGridScreen> createState() => ArtistsGridScreenState();
}

class ArtistsGridScreenState extends State<ArtistsGridScreen> {
  late Future<List<Uint8List>> _imageFutures;

  Future<List<Uint8List>> loadImages() async {
    final api = await SpotifyApiService.api;
    List<String> artistIDs = [
      "2n2RSaZqBuUUukhbLlpnE6",
      "2n2RSaZqBuUUukhbLlpnE6"
    ];
    List<Uint8List> allImages = [];
    for (String id in artistIDs) {
      final url = await api.getArtistImageURL(id);
      final img = await api.getImage(url);
      allImages.add(img);
    }
    return allImages;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageFutures = loadImages();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: FutureBuilder<List<Uint8List>>(
          future: _imageFutures,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                itemExtent: 300,
                // itemCount: snapshot.data!.length,
                itemCount: 2,
                itemBuilder: (context, index) {
                  final imageItem = snapshot.data![index];
                  return Card(
                    // Added a Card for better visual separation
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.memory(imageItem,
                              scale: 0.01,
                              // fit: BoxFit.cover,
                              height: 20, // Fixed height for consistent display
                              width: 20,
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                      child: Text('Error loading image'))),
                          // Text("ArtistName", style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            /// handles others as you did on question
            else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
