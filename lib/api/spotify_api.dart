import 'dart:convert';

import 'dart:html';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:spotify_sdk/spotify_sdk_web.dart';
import 'package:synchronized/synchronized.dart' as synchronized;

class SpotifyApiService {
  final String clientId = dotenv.env['CLIENT_ID'].toString();
  // final String clientSecret = dotenv.env['CLIENT_SECRET'].toString();
  final String redirectUri = dotenv.env['REDIRECT_URL'].toString();
  final String authEndpoint = 'https://accounts.spotify.com/authorize';
  final String tokenEndpoint = 'https://accounts.spotify.com/api/token';
  final String apiBaseUrl = 'https://api.spotify.com/v1';

  static final SpotifyApiService _instance = SpotifyApiService._internal();
  static late final SpotifyApi _api;
  static bool _initialized = false;

  SpotifyApiService._internal();

  factory SpotifyApiService() {
    return _instance;
  }

  static Future<void> _init() async {
    if (!_initialized) {
      _api = SpotifyApi();
      _initialized = true;
    }
  }

  static Future<SpotifyApi> get api async {
    await _init();
    return _api;
  }
}

class SpotifyApi {
  final String clientId = dotenv.env['CLIENT_ID'].toString();
  // final String clientSecret = dotenv.env['CLIENT_SECRET'].toString();
  final String redirectUri = dotenv.env['REDIRECT_URL'].toString();
  final String authEndpoint = 'https://accounts.spotify.com/authorize';
  final String tokenEndpoint = 'https://accounts.spotify.com/api/token';
  final String apiBaseUrl = 'https://api.spotify.com/v1';

  final Dio _dio = Dio();
  late SharedPreferences _prefs;

  String? _accessToken;

  final synchronized.Lock _getTokenLock = synchronized.Lock(reentrant: true);
  SpotifyToken? _spotifyToken;

  // Need a separate Dio for auth only, that does always attach current token
  final Dio _authDio = Dio(BaseOptions());

  static String? tokenSwapURL;
  static String? tokenRefreshURL;

  ///
  /// Creates a code verifier as per
  /// https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
  String _createCodeVerifier() {
    return _createRandomString(127);
  }

  /// Creates a code challenge as per
  /// https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
  String _createCodeChallenge(String codeVerifier) {
    return base64Url
        .encode(sha256.convert(ascii.encode(codeVerifier)).bytes)
        .replaceAll('=', '');
  }

  /// Creates a random string unique to a given authentication session.
  String _createAuthState() {
    return _createRandomString(64);
  }

  /// Creates a cryptographically random string.
  String _createRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return List.generate(
        128, (i) => chars[math.Random.secure().nextInt(chars.length)]).join();
  }

  Future<String> _authorizeSpotify(
      {required String clientId,
      required String redirectUrl,
      required String? scopes}) async {
    // creating auth uri
    var codeVerifier = _createCodeVerifier();
    var codeChallenge = _createCodeChallenge(codeVerifier);
    var state = _createAuthState();

    var params = {
      'client_id': clientId,
      'redirect_uri': redirectUrl,
      'response_type': 'code',
      'state': state,
      'scope': scopes,
    };

    if (tokenSwapURL == null) {
      params['code_challenge_method'] = 'S256';
      params['code_challenge'] = codeChallenge;
    }

    final authorizationUri = Uri.https(
      'accounts.spotify.com',
      'authorize',
      params,
    );

    // opening auth window
    var authPopup = window.open(
      authorizationUri.toString(),
      'Spotify Authorization',
    );
    String? message;
    var sub = window.onMessage.listen(allowInterop((event) {
      message = event.data.toString();
      // ensure the message contains auth code
      if (!message!.startsWith('?code=')) {
        message = null;
      }
    }));

    // loop and wait for auth
    while (authPopup.closed == false && message == null) {
      // await response from the window
      await Future.delayed(const Duration(milliseconds: 250));
    }

    // error if window closed by user
    if (message == null) {
      throw PlatformException(
          message: 'User closed authentication window',
          code: 'Authentication Error');
    }

    // parse the returned parameters
    var parsedMessage = Uri.parse(message!);

    // check if state is the same
    if (state != parsedMessage.queryParameters['state']) {
      throw PlatformException(
          message: 'Invalid state', code: 'Authentication Error');
    }

    // check for error
    if (parsedMessage.queryParameters['error'] != null ||
        parsedMessage.queryParameters['code'] == null) {
      throw PlatformException(
          message: "${parsedMessage.queryParameters['error']}",
          code: 'Authentication Error');
    }

    // close auth window
    if (authPopup.closed == false) {
      authPopup.close();
    }
    await sub.cancel();

    // exchange auth code for access and refresh tokens
    dynamic authResponse;

    RequestOptions req;

    if (tokenSwapURL == null) {
      // build request to exchange auth code with PKCE for access and refresh tokens
      req = RequestOptions(
        path: 'https://accounts.spotify.com/api/token',
        method: 'POST',
        data: {
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'code': parsedMessage.queryParameters['code'],
          'redirect_uri': redirectUrl,
          'code_verifier': codeVerifier
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    } else {
      // or build request to exchange code with token swap
      // https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
      req = RequestOptions(
        path: tokenSwapURL!,
        method: 'POST',
        data: {
          'code': parsedMessage.queryParameters['code'],
          'redirect_uri': redirectUrl,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    }

    try {
      var res = await _authDio.fetch(req);
      authResponse = res.data;
    } on DioException catch (e) {
      Log.log('Spotify auth error: ${e.response?.data}');
      rethrow;
    }

    _spotifyToken = SpotifyToken(
        clientId: clientId,
        accessToken: authResponse['access_token'] as String,
        refreshToken: authResponse['refresh_token'] as String,
        expiry: (DateTime.now().millisecondsSinceEpoch / 1000).round() +
            (authResponse['expires_in'] as int));
    return _spotifyToken!.accessToken;
  }

  Future<bool> connectToSpotify() async {
    // TODO: Handle already connected
    // if (_currentPlayer != null) {
    //   return true;
    // }
    Log.log('Connecting to Spotify...');

    var redirectUrl = redirectUri;
    // var playerName = call.arguments[ParamNames.playerName] as String?;
    var scopes =
        'streaming, user-read-playback-state, user-modify-playback-state, user-read-currently-playing, user-read-email, user-read-private';

    // get initial token
    await _authorizeSpotify(
        clientId: clientId, redirectUrl: redirectUrl, scopes: scopes);
    await _getSpotifyAuthToken();

    return true;
  }

  Future<dynamic> _refreshSpotifyToken(
      String? clientId, String? refreshToken) async {
    RequestOptions req;
    if (tokenRefreshURL == null) {
      // build request to refresh PKCE for access and refresh tokens
      req = RequestOptions(
        path: 'https://accounts.spotify.com/api/token',
        method: 'POST',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    } else {
      // or build request to refresh code with token swap
      // https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
      req = RequestOptions(
        path: tokenRefreshURL!,
        method: 'POST',
        data: {
          'refresh_token': refreshToken,
        },
        contentType: Headers.formUrlEncodedContentType,
      );
    }

    try {
      var res = await _authDio.fetch(req);
      var d = res.data;
      d['refresh_token'] = refreshToken;
      return d;
    } on DioException catch (e) {
      Log.log('Token refresh error: ${e.response?.data}');
      rethrow;
    }
  }

  Future<String> _getSpotifyAuthToken() async {
    return await _getTokenLock.synchronized<String>(() async {
      Log.log("In start");
      if (_spotifyToken?.accessToken != null) {
        Log.log("In first if");
        // attempt to use the previously authorized credentials
        if (_spotifyToken!.expiry >
            DateTime.now().millisecondsSinceEpoch / 1000) {
          Log.log("In exp");
          // access token valid
          return "foo";
          return _spotifyToken!.accessToken;
        } else {
          Log.log("In else");
          // access token invalid, refresh it
          var newToken = await _refreshSpotifyToken(
              _spotifyToken!.clientId, _spotifyToken!.refreshToken);
          Log.log(newToken.toString());
          _spotifyToken = SpotifyToken(
              clientId: _spotifyToken!.clientId,
              accessToken: newToken['access_token'] as String,
              refreshToken: newToken['refresh_token'] as String,
              expiry: (DateTime.now().millisecondsSinceEpoch / 1000).round() +
                  (newToken['expires_in'] as int));
          return _spotifyToken!.accessToken;
        }
      } else {
        throw PlatformException(
            message: 'Spotify user not logged in!',
            code: 'Authentication Error');
      }
    });
  }

  SpotifyApi() {
    _init();
  }

  Future<void> _init() async {
    // Access token
    _prefs = await SharedPreferences.getInstance();
    // _accessToken = _prefs.getString('spotify_access_token');
    // Dio cache
    late CacheStore cacheStore;
    cacheStore = HiveCacheStore(null);

    // Global cache options
    final cacheOptions = CacheOptions(
      // A default store is required for interceptor.
      store: cacheStore,

      // All subsequent fields are optional.

      // Default.
      policy: CachePolicy.forceCache,
      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [401, 403],
      // Overrides any HTTP directive to delete entry past this duration.
      // Useful only when origin server has no cache config or custom behaviour is desired.
      // Defaults to [null].
      maxStale: const Duration(days: 7),
      // Default. Allows 3 cache sets and ease cleanup.
      priority: CachePriority.normal,
      // Default. Body and headers encryption with your own algorithm.
      cipher: null,
      // Default. Key builder to retrieve requests.
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      // Default. Allows to cache POST requests.
      // Overriding [keyBuilder] is strongly recommended when [true].
      allowPostMethod: false,
    );

    _dio.options.baseUrl = apiBaseUrl;
    // Add token handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // if (_accessToken != null) {
        if (_spotifyToken != null) {
          if (_spotifyToken!.expiry >
              DateTime.now().millisecondsSinceEpoch / 1000) {
            Log.log("Token not expired");
            options.headers['Authorization'] =
                'Bearer ${_spotifyToken!.accessToken}';
          } else {
            Log.log("Token expired");
            options.headers['Authorization'] =
                'Bearer ${await _getSpotifyAuthToken()}';
          }
          // options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, try to refresh
          if (await _getSpotifyAuthToken() != "") {
            Log.log("Await new token");

            // Retry the original request
            return handler.resolve(await _retry(e.requestOptions));
          } else {
            // Refresh failed, propagate the error
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));
    // Add cache
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  // Future<bool> _refreshTokenFunc() async {
  //   final credentials = "$clientId:$clientSecret";
  //   String encoded = base64.encode(utf8.encode(credentials));
  //   try {
  //     final response = await Dio().post(
  //       tokenEndpoint,
  //       data: {
  //         'grant_type': 'client_credentials',
  //       },
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Basic $encoded',
  //           'Content-Type': 'application/x-www-form-urlencoded'
  //         },
  //       ),
  //     );
  //
  //     _accessToken = response.data['access_token'];
  //
  //     await _prefs.setString('spotify_access_token', _accessToken!);
  //     return true;
  //   } catch (e) {
  //     // Handle refresh token error (e.g., token revoked)
  //     await _prefs.remove('spotify_access_token');
  //     _accessToken = null;
  //     return false;
  //   }
  // }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  // Future<String> getArtistImageURL(String id) async {
  //   Log.log("Getting artist");
  //   String url = "https://api.spotify.com/v1/artists/$id";
  //   final response = await get(url);
  //   Log.log(response.statusCode.toString());
  //   try {
  //     final Map<String, dynamic> jsonData = response.data;
  //     String albumUrl = jsonData["images"][0]["url"];
  //     return albumUrl;
  //   } on Exception catch (e) {
  //     // setStatus(e.toString());
  //     rethrow;
  //   }
  // }

  Future<Uint8List> getImage(String imageURL) async {
    final thisDio = Dio();
    Uint8List imageData;
    final response = await thisDio.get(imageURL,
        options: Options(responseType: ResponseType.bytes));
    // final response = await get(imageURL);
    try {
      imageData = Uint8List.fromList(response.data.toList());
      return imageData;
    } on Exception catch (e) {
      Log.log(e.toString());
      rethrow;
    }
  }
}
