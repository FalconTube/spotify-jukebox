import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/spotify_sdk_web.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';

class AllSDKFuncs {
  String token = "";
  Future<void> connectToSpotifyRemote() async {
    try {
      token = await getAccessToken();
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: "240ac9748340493fb136500a0e3acd95",
          redirectUrl: "http://localhost:44344/",
          playerName: "Small Player",
          accessToken: token);

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

  Future<String> getAccessToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: "240ac9748340493fb136500a0e3acd95",
        redirectUrl: "http://localhost:44344/",
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

  Future<void> play() async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:track:0hKjGGWCAthLTNAbO5drvs');
    } on PlatformException catch (e) {
      Log.log(e.code, message: e.message);
    } on MissingPluginException {
      Log.log('not implemented');
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      Log.log(e.code, message: e.message);
    } on MissingPluginException {
      Log.log('not implemented');
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      Log.log(e.code, message: e.message);
    } on MissingPluginException {
      Log.log('not implemented');
    }
  }

  Future<void> logout() async {
    var result = await SpotifySdk.disconnect();
  }
}
