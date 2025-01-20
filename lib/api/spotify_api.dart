import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jukebox_spotify_flutter/classes/track.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:jukebox_spotify_flutter/classes/mock_interceptor.dart';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyApiService {
  final String clientId = dotenv.get('CLIENT_ID');
  final String redirectUri = dotenv.get('REDIRECT_URL');
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
  final String clientId = dotenv.get('CLIENT_ID');
  // final String clientSecret = dotenv.env['CLIENT_SECRET'].toString();
  final String redirectUri = dotenv.get('REDIRECT_URL');
  final String authEndpoint = 'https://accounts.spotify.com/authorize';
  final String tokenEndpoint = 'https://accounts.spotify.com/api/token';
  final String apiBaseUrl = 'https://api.spotify.com/v1';

  final Dio _dio = Dio();
  final Dio _dioNoCache = Dio();

  SpotifyApi() {
    _init();
  }

  Future<void> _init() async {
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
    _dioNoCache.options.baseUrl = apiBaseUrl;

    // Add mock interceptor, if in development mode
    final doMock = dotenv.getBool("MOCK_API", fallback: false);
    Log.log("Mock is: $doMock");
    if (doMock == true) {
      _dio.interceptors.add(MockInterceptor());
      _dioNoCache.interceptors.add(MockInterceptor());
    }

    // Add token handling
    final authInterceptor = InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['Authorization'] =
            'Bearer ${await SpotifySdk.getSpotifyAuthToken()}';
        // if (_spotifyToken != null) {
        //   options.headers['Authorization'] =
        //       'Bearer ${await SpotifySdk.getSpotifyAuthToken()}';
        // }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, try to refresh
          if (await SpotifySdk.getSpotifyAuthToken() != "") {
            // Retry the original request
            return handler.resolve(await _retry(e.requestOptions));
          } else {
            // Refresh failed, propagate the error
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    );
    // Add token handling
    _dio.interceptors.add(authInterceptor);
    _dioNoCache.interceptors.add(authInterceptor);

    // Add cache
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

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
      {Map<String, dynamic>? queryParameters,
      Options? options,
      bool withoutCache = false}) async {
    if (withoutCache == true) {
      return _dioNoCache.get(path,
          queryParameters: queryParameters, options: options);
    }
    return _dio.get(path, queryParameters: queryParameters, options: options);
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

  Future<String?> getDeviceID() async {
    String uri = "https://api.spotify.com/v1/me/player/devices";
    final out = await get(uri, withoutCache: true);
    final devices = out.data["devices"];
    // final deviceId = out.data["devices"][0]["id"];
    String? deviceId;
    for (final device in devices) {
      final name = device["name"];
      if (name != "Jukebox") continue;
      deviceId = device["id"];
    }
    return deviceId;
  }

  Future<int> getTrackDuration(String trackUri) async {
    String uri = "https://api.spotify.com/v1/tracks/$trackUri";
    final out = await get(uri);
    final track = SimpleTrack.fromJson(out.data);

    return track.durationMs;
  }

  /// Plays a [spotifyUri] and assumes that it is a playlist
  /// If [selectOnly] is true, will immediately stop playback
  Future<void> playOrSelectPlaylist(String spotifyUri,
      {bool selectOnly = false}) async {
    // Set content type

    // Prepare data
    final data = {
      "context_uri": "spotify:playlist:$spotifyUri",
      "position_ms": 0,
    };

    final deviceId = await getDeviceID();
    if (deviceId == null) {
      throw Exception("Could not obtain device ID of Jukebox");
    }

    try {
      await _dio.put(
        'https://api.spotify.com/v1/me/player/play?device_id=$deviceId',
        options: Options(contentType: Headers.jsonContentType),
        data: data,
      );
    } on DioException catch (e) {
      // Handle error
      Log.log(e.error);
      rethrow;
    }
    await Future.delayed(Duration(milliseconds: 1000));
    if (selectOnly == false) return;

    // Now pause if selectOnly is true
    try {
      await _dio.put(
        'https://api.spotify.com/v1/me/player/pause?device_id=$deviceId',
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      // Handle error
      Log.log(e.error);
      rethrow;
    }
  }
}
