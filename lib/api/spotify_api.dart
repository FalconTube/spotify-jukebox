import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import 'package:logger/logger.dart';

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
    _prefs = await SharedPreferences.getInstance();
    _accessToken = _prefs.getString('spotify_access_token');
    // setStatus(_accessToken);

    _dio.options.baseUrl = apiBaseUrl;
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

  Future<String> getArtistImageURL(String id) async {
    String url = "https://api.spotify.com/v1/artists/$id";
    final response = await get(url);
    try {
      final Map<String, dynamic> jsonData = response.data;
      String albumUrl = jsonData["images"][0]["url"];
      return albumUrl;
    } on Exception catch (e) {
      // setStatus(e.toString());
      rethrow;
    }
  }

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
      setStatus(e.toString());
      rethrow;
    }
  }

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
  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
    // print('$code$text');
  }
}
