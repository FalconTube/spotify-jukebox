import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jukebox_spotify_flutter/logging/pretty_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

class SpotifyApiService {
  final String clientId = dotenv.env['CLIENT_ID'].toString();
  final String clientSecret = dotenv.env['CLIENT_SECRET'].toString();
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
  final String clientSecret = dotenv.env['CLIENT_SECRET'].toString();
  final String redirectUri = dotenv.env['REDIRECT_URL'].toString();
  final String authEndpoint = 'https://accounts.spotify.com/authorize';
  final String tokenEndpoint = 'https://accounts.spotify.com/api/token';
  final String apiBaseUrl = 'https://api.spotify.com/v1';

  final Dio _dio = Dio();
  late SharedPreferences _prefs;

  String? _accessToken;

  SpotifyApi() {
    _init();
  }

  Future<void> _init() async {
    // Access token
    _prefs = await SharedPreferences.getInstance();
    _accessToken = _prefs.getString('spotify_access_token');
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
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, try to refresh
          if (await _refreshTokenFunc()) {
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

  Future<bool> _refreshTokenFunc() async {
    final credentials = "$clientId:$clientSecret";
    String encoded = base64.encode(utf8.encode(credentials));
    try {
      final response = await Dio().post(
        tokenEndpoint,
        data: {
          'grant_type': 'client_credentials',
        },
        options: Options(
          headers: {
            'Authorization': 'Basic $encoded',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
        ),
      );

      _accessToken = response.data['access_token'];

      await _prefs.setString('spotify_access_token', _accessToken!);
      return true;
    } catch (e) {
      // Handle refresh token error (e.g., token revoked)
      await _prefs.remove('spotify_access_token');
      _accessToken = null;
      return false;
    }
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
