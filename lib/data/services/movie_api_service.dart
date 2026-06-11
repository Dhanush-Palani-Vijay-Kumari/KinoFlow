import 'package:dio/dio.dart';
import '../../domain/entities/movie.dart';
import '../datasources/mock_movie_data.dart';

/// REST API service using Dio.
/// Uses TMDB-style JSON structure.
/// Falls back to mock data when API key is not configured.
class MovieApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBase = 'https://image.tmdb.org/t/p/w500';

  // Replace with your TMDB API key in production
  static const String _apiKey = 'YOUR_TMDB_API_KEY';

  late final Dio _dio;

  MovieApiService({Dio? dio}) {
    _dio = dio ??
        Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

    // Add request/response logging in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: true,
    ));

    // Add retry interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        handler.next(error);
      },
    ));
  }

  // ── Fetch now-playing movies from TMDB REST API ────────────────────
  Future<List<Movie>> fetchNowPlaying({String language = 'en-US'}) async {
    if (_apiKey == 'YOUR_TMDB_API_KEY') {
      // API key not configured — fall back to local data
      return MockMovieData.movies;
    }

    try {
      final response = await _dio.get(
        '/movie/now_playing',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
          'page': 1,
        },
      );

      final List results = response.data['results'] as List;
      return results.map((json) => _movieFromTmdb(json)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      return MockMovieData.movies;
    }
  }

  // ── Search movies by query string ──────────────────────────────────
  Future<List<Movie>> searchMovies(String query, {String language = 'en-US'}) async {
    if (_apiKey == 'YOUR_TMDB_API_KEY' || query.isEmpty) {
      return MockMovieData.searchMovies(query);
    }

    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'language': language,
          'page': 1,
        },
      );

      final List results = response.data['results'] as List;
      return results.map((json) => _movieFromTmdb(json)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      return MockMovieData.searchMovies(query);
    }
  }

  // ── Fetch movie details by TMDB ID ─────────────────────────────────
  Future<Movie?> fetchMovieDetails(int tmdbId) async {
    if (_apiKey == 'YOUR_TMDB_API_KEY') return null;

    try {
      final response = await _dio.get(
        '/movie/$tmdbId',
        queryParameters: {
          'api_key': _apiKey,
          'append_to_response': 'credits',
        },
      );

      return _movieFromTmdb(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }

  // ── Map TMDB JSON response → Movie entity ──────────────────────────
  Movie _movieFromTmdb(Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final backdropPath = json['backdrop_path'] as String?;

    // Extract cast from credits if available
    final credits = json['credits'] as Map<String, dynamic>?;
    final castList = credits?['cast'] as List<dynamic>?;
    final cast = castList
            ?.take(5)
            .map((c) => c['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList() ??
        [];

    final genreList = json['genres'] as List<dynamic>?;
    final genres = genreList
            ?.map((g) => g['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList() ??
        ['Drama'];

    // Detect German-language films
    final originalLanguage = json['original_language'] as String? ?? '';
    final isGerman = originalLanguage == 'de';

    return Movie(
      id: 'tmdb_${json['id']}',
      title: json['title'] as String? ?? '',
      titleDe: isGerman ? (json['title'] as String? ?? '') : '',
      synopsis: json['overview'] as String? ?? '',
      synopsisDe: '',
      posterUrl: posterPath != null ? '$_imageBase$posterPath' : '',
      backdropUrl: backdropPath != null
          ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
          : '',
      director: '',
      cast: cast,
      genres: genres,
      language: _languageName(originalLanguage),
      durationMinutes: (json['runtime'] as num?)?.toInt() ?? 0,
      rating: ((json['vote_average'] as num?)?.toDouble() ?? 0.0),
      releaseDate: (json['release_date'] as String? ?? '').substring(0, 4),
      isGerman: isGerman,
      isFeatured: (json['vote_average'] as num?)?.toDouble() ?? 0 > 7.5,
    );
  }

  // ── Map ISO 639-1 code → readable language name ───────────────────
  String _languageName(String code) {
    const map = {
      'de': 'Deutsch',
      'en': 'English',
      'fr': 'Français',
      'es': 'Español',
      'it': 'Italiano',
      'ko': 'Korean',
      'ja': 'Japanese',
    };
    return map[code] ?? code.toUpperCase();
  }

  // ── Structured Dio error handling ────────────────────────────────
  void _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        // Timeout — will fall through to mock data
        break;
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) {
          // Invalid API key
        } else if (status == 429) {
          // Rate limited
        }
        break;
      case DioExceptionType.connectionError:
        // No internet — will fall through to mock data
        break;
      default:
        break;
    }
  }
}
