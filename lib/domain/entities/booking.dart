import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String movieId;
  final String movieTitle;
  final String posterUrl;
  final String showtimeId;
  final String cinemaName;
  final DateTime dateTime;
  final List<String> selectedSeats;
  final double totalPrice;
  final String userId;
  final DateTime bookedAt;

  const Booking({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.posterUrl,
    required this.showtimeId,
    required this.cinemaName,
    required this.dateTime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.userId,
    required this.bookedAt,
  });

  @override
  List<Object?> get props => [id, movieId, showtimeId, userId];
}
