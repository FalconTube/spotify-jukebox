import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';

class AllSDKFuncs {
  static Future<void> connectToSpotifyRemote() async {
    // String token = "";
    try {
      // token = await AllSDKFuncs.getAccessToken();

      String clientId = dotenv.env['CLIENT_ID'].toString();
      String redirectUrl = dotenv.env['REDIRECT_URL'].toString();
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: clientId,
          redirectUrl: redirectUrl,
          playerName: "Large Player");
      // accessToken: token);

      Log.log(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
    } on PlatformException catch (e) {
      Log.log(e.code, message: e.message);
    } on MissingPluginException {
      Log.log('not implemented');
    }
  }

  Future<void> deleteToken() async {}

  static Future<String> getAccessToken() async {
    try {
      String clientId = dotenv.env['CLIENT_ID'].toString();
      String redirectUrl = dotenv.env['REDIRECT_URL'].toString();
      var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUrl,
        scope:
            'streaming, user-read-playback-state, user-modify-playback-state, user-read-currently-playing, user-read-email, user-read-private',
      );
      Log.log('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      Log.log(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      Log.log('not implemented');
      return Future.error('not implemented');
    }
  }

  static Future<void> play(String track) async {
    try {
      // await SpotifySdk.play(spotifyUri: 'spotify:track:0hKjGGWCAthLTNAbO5drvs');
      await SpotifySdk.play(spotifyUri: track);
    } on PlatformException catch (e) {
      Log.log(e.code, message: e.message);
    } on MissingPluginException {
      Log.log('not implemented');
    }
  }

  static Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      Log.log(e.code, message: e.message);
    } on MissingPluginException {
      Log.log('not implemented');
    }
  }

  static Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      Log.log(e.code, message: e.message);
    } on MissingPluginException {
      Log.log('not implemented');
    }
  }

  static Future<void> logout() async {
    var result = await SpotifySdk.disconnect();
    Log.log(result);
  }
}
