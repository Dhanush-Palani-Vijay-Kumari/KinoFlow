import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/booking.dart';
import '../../data/repositories/booking_repository.dart';
import '../../core/constants/app_constants.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class SelectShowtime extends BookingEvent {
  final Showtime showtime;
  final Movie movie;
  const SelectShowtime({required this.showtime, required this.movie});
  @override
  List<Object?> get props => [showtime.id];
}

class ToggleSeat extends BookingEvent {
  final String seatId;
  const ToggleSeat(this.seatId);
  @override
  List<Object?> get props => [seatId];
}

class ConfirmBooking extends BookingEvent {}

class LoadMyBookings extends BookingEvent {}

class ResetBooking extends BookingEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingShowtimeSelected extends BookingState {
  final Showtime showtime;
  final Movie movie;
  final List<String> selectedSeats;

  const BookingShowtimeSelected({
    required this.showtime,
    required this.movie,
    this.selectedSeats = const [],
  });

  double get totalPrice => selectedSeats.length * showtime.price;

  BookingShowtimeSelected copyWith({List<String>? selectedSeats}) {
    return BookingShowtimeSelected(
      showtime: showtime,
      movie: movie,
      selectedSeats: selectedSeats ?? this.selectedSeats,
    );
  }

  @override
  List<Object?> get props => [showtime.id, selectedSeats];
}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final Booking booking;
  const BookingSuccess(this.booking);
  @override
  List<Object?> get props => [booking.id];
}

class MyBookingsLoaded extends BookingState {
  final List<Booking> bookings;
  const MyBookingsLoaded(this.bookings);
  @override
  List<Object?> get props => [bookings];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _repository;

  BookingBloc(this._repository) : super(BookingInitial()) {
    on<SelectShowtime>(_onSelectShowtime);
    on<ToggleSeat>(_onToggleSeat);
    on<ConfirmBooking>(_onConfirmBooking);
    on<LoadMyBookings>(_onLoadMyBookings);
    on<ResetBooking>(_onResetBooking);
  }

  void _onSelectShowtime(SelectShowtime event, Emitter<BookingState> emit) {
    emit(BookingShowtimeSelected(
      showtime: event.showtime,
      movie: event.movie,
    ));
  }

  void _onToggleSeat(ToggleSeat event, Emitter<BookingState> emit) {
    if (state is BookingShowtimeSelected) {
      final current = state as BookingShowtimeSelected;
      final seats = List<String>.from(current.selectedSeats);
      if (seats.contains(event.seatId)) {
        seats.remove(event.seatId);
      } else {
        seats.add(event.seatId);
      }
      emit(current.copyWith(selectedSeats: seats));
    }
  }

  Future<void> _onConfirmBooking(
      ConfirmBooking event, Emitter<BookingState> emit) async {
    if (state is! BookingShowtimeSelected) return;
    final current = state as BookingShowtimeSelected;
    if (current.selectedSeats.isEmpty) {
      emit(const BookingError('Please select at least one seat'));
      return;
    }

    emit(BookingLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AppConstants.keyUserId) ?? 'guest';

      final booking = Booking(
        id: const Uuid().v4(),
        movieId: current.movie.id,
        movieTitle: current.movie.title,
        posterUrl: current.movie.posterUrl,
        showtimeId: current.showtime.id,
        cinemaName: current.showtime.cinemaName,
        dateTime: current.showtime.dateTime,
        selectedSeats: current.selectedSeats,
        totalPrice: current.totalPrice,
        userId: userId,
        bookedAt: DateTime.now(),
      );

      await _repository.saveBooking(booking);
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onLoadMyBookings(
      LoadMyBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final bookings = await _repository.getMyBookings();
      emit(MyBookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  void _onResetBooking(ResetBooking event, Emitter<BookingState> emit) {
    emit(BookingInitial());
  }
}
