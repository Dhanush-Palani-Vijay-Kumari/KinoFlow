import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final String id;
  final String title;
  final String titleDe;
  final String synopsis;
  final String synopsisDe;
  final String posterUrl;
  final String backdropUrl;
  final String director;
  final List<String> cast;
  final List<String> genres;
  final String language;
  final int durationMinutes;
  final double rating;
  final String releaseDate;
  final bool isGerman;
  final bool isFeatured;
  final List<Showtime> showtimes;

  const Movie({
    required this.id,
    required this.title,
    required this.titleDe,
    required this.synopsis,
    required this.synopsisDe,
    required this.posterUrl,
    required this.backdropUrl,
    required this.director,
    required this.cast,
    required this.genres,
    required this.language,
    required this.durationMinutes,
    required this.rating,
    required this.releaseDate,
    required this.isGerman,
    this.isFeatured = false,
    this.showtimes = const [],
  });

  String localizedTitle(String locale) =>
      locale == 'de' && titleDe.isNotEmpty ? titleDe : title;

  String localizedSynopsis(String locale) =>
      locale == 'de' && synopsisDe.isNotEmpty ? synopsisDe : synopsis;

  @override
  List<Object?> get props => [id, title, posterUrl];
}

class Showtime extends Equatable {
  final String id;
  final String movieId;
  final String cinemaName;
  final DateTime dateTime;
  final String hall;
  final double price;
  final List<String> bookedSeats;

  const Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaName,
    required this.dateTime,
    required this.hall,
    required this.price,
    this.bookedSeats = const [],
  });

  @override
  List<Object?> get props => [id, movieId, dateTime];
}
