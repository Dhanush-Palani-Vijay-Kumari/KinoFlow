import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasources/mock_movie_data.dart';
import '../../domain/entities/movie.dart';

class MovieRepository {
  final FirebaseFirestore _firestore;

  MovieRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Fetch all movies from Firestore ────────────────────────────────
  // Falls back to MockMovieData if Firestore is unreachable or empty.
  Future<List<Movie>> fetchAllMovies() async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('rating', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        // Firestore empty — seed from mock and return mock
        await _seedFirestore();
        return MockMovieData.movies;
      }

      return snapshot.docs
          .map((doc) => _movieFromFirestore(doc))
          .toList();
    } catch (_) {
      // Offline or permission error — use local mock data
      return MockMovieData.movies;
    }
  }

  // ── Fetch a single movie by ID ─────────────────────────────────────
  Future<Movie?> fetchMovieById(String id) async {
    try {
      final doc = await _firestore.collection('movies').doc(id).get();
      if (!doc.exists) return MockMovieData.getMovieById(id);
      return _movieFromFirestore(doc);
    } catch (_) {
      return MockMovieData.getMovieById(id);
    }
  }

  // ── Search movies by title (Firestore array-contains-any) ─────────
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return fetchAllMovies();

    try {
      // Firestore doesn't support full-text search natively;
      // use client-side filter on fetched list (works for small datasets).
      final all = await fetchAllMovies();
      final q = query.toLowerCase();
      return all
          .where((m) =>
              m.title.toLowerCase().contains(q) ||
              m.titleDe.toLowerCase().contains(q) ||
              m.director.toLowerCase().contains(q) ||
              m.genres.any((g) => g.toLowerCase().contains(q)))
          .toList();
    } catch (_) {
      return MockMovieData.searchMovies(query);
    }
  }

  // ── Filter by category ─────────────────────────────────────────────
  Future<List<Movie>> fetchByFilter(String filter) async {
    try {
      final all = await fetchAllMovies();
      switch (filter) {
        case 'german':
          return all.where((m) => m.isGerman).toList();
        case 'international':
          return all.where((m) => !m.isGerman).toList();
        default:
          return all;
      }
    } catch (_) {
      switch (filter) {
        case 'german':
          return MockMovieData.getGermanMovies();
        case 'international':
          return MockMovieData.getInternationalMovies();
        default:
          return MockMovieData.movies;
      }
    }
  }

  // ── Synchronous getters (used by BLoC for instant local results) ───
  List<Movie> getAllMovies() => MockMovieData.movies;
  List<Movie> getFeaturedMovies() => MockMovieData.getFeaturedMovies();
  List<Movie> getGermanMovies() => MockMovieData.getGermanMovies();
  List<Movie> getInternationalMovies() => MockMovieData.getInternationalMovies();
  Movie? getMovieById(String id) => MockMovieData.getMovieById(id);
  List<Movie> searchMoviesSync(String query) => MockMovieData.searchMovies(query);

  // ── Map Firestore document → Movie entity ──────────────────────────
  Movie _movieFromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final showtimesRaw =
        (d['showtimes'] as List<dynamic>?) ?? [];

    return Movie(
      id: doc.id,
      title: d['title'] as String? ?? '',
      titleDe: d['titleDe'] as String? ?? '',
      synopsis: d['synopsis'] as String? ?? '',
      synopsisDe: d['synopsisDe'] as String? ?? '',
      posterUrl: d['posterUrl'] as String? ?? '',
      backdropUrl: d['backdropUrl'] as String? ?? '',
      director: d['director'] as String? ?? '',
      cast: List<String>.from(d['cast'] ?? []),
      genres: List<String>.from(d['genres'] ?? []),
      language: d['language'] as String? ?? '',
      durationMinutes: (d['durationMinutes'] as num?)?.toInt() ?? 0,
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      releaseDate: d['releaseDate'] as String? ?? '',
      isGerman: d['isGerman'] as bool? ?? false,
      isFeatured: d['isFeatured'] as bool? ?? false,
      showtimes: showtimesRaw
          .map((s) => _showtimeFromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Showtime _showtimeFromMap(Map<String, dynamic> s) {
    return Showtime(
      id: s['id'] as String? ?? '',
      movieId: s['movieId'] as String? ?? '',
      cinemaName: s['cinemaName'] as String? ?? '',
      dateTime: s['dateTime'] is Timestamp
          ? (s['dateTime'] as Timestamp).toDate()
          : DateTime.parse(s['dateTime'] as String),
      hall: s['hall'] as String? ?? '',
      price: (s['price'] as num?)?.toDouble() ?? 12.0,
      bookedSeats: List<String>.from(s['bookedSeats'] ?? []),
    );
  }

  // ── Seed Firestore with mock data (one-time setup) ────────────────
  Future<void> _seedFirestore() async {
    try {
      final batch = _firestore.batch();
      for (final movie in MockMovieData.movies) {
        final ref = _firestore.collection('movies').doc(movie.id);
        batch.set(ref, {
          'title': movie.title,
          'titleDe': movie.titleDe,
          'synopsis': movie.synopsis,
          'synopsisDe': movie.synopsisDe,
          'posterUrl': movie.posterUrl,
          'backdropUrl': movie.backdropUrl,
          'director': movie.director,
          'cast': movie.cast,
          'genres': movie.genres,
          'language': movie.language,
          'durationMinutes': movie.durationMinutes,
          'rating': movie.rating,
          'releaseDate': movie.releaseDate,
          'isGerman': movie.isGerman,
          'isFeatured': movie.isFeatured,
          'showtimes': movie.showtimes
              .map((st) => {
                    'id': st.id,
                    'movieId': st.movieId,
                    'cinemaName': st.cinemaName,
                    'dateTime': Timestamp.fromDate(st.dateTime),
                    'hall': st.hall,
                    'price': st.price,
                    'bookedSeats': st.bookedSeats,
                  })
              .toList(),
        });
      }
      await batch.commit();
    } catch (_) {
      // Seeding is best-effort — ignore failures
    }
  }
}
