import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/booking.dart';
import '../../core/constants/app_constants.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Fetch user's bookings from Firestore ───────────────────────────
  Future<List<Booking>> getMyBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.keyUserId) ?? '';
    if (userId.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('bookedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _bookingFromFirestore(doc))
          .toList();
    } catch (_) {
      // Fallback to SharedPreferences cache if Firestore unreachable
      return _getLocalBookings(userId);
    }
  }

  // ── Save a booking to Firestore + local cache ──────────────────────
  Future<void> saveBooking(Booking booking) async {
    // Always save locally first (offline-first)
    await _saveLocalBooking(booking);

    // Then sync to Firestore
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(_bookingToMap(booking));
    } catch (_) {
      // Local save succeeded — Firestore will sync when back online
    }
  }

  // ── Real-time booking listener (stream) ───────────────────────────
  Stream<List<Booking>> bookingsStream(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => _bookingFromFirestore(doc)).toList());
  }

  // ── Mark a seat as booked on the showtime document ────────────────
  Future<void> markSeatBooked({
    required String movieId,
    required String showtimeId,
    required List<String> seats,
  }) async {
    try {
      final movieRef = _firestore.collection('movies').doc(movieId);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(movieRef);
        if (!snap.exists) return;

        final showtimes =
            List<Map<String, dynamic>>.from(snap.data()?['showtimes'] ?? []);

        final idx = showtimes.indexWhere((st) => st['id'] == showtimeId);
        if (idx == -1) return;

        final existing =
            List<String>.from(showtimes[idx]['bookedSeats'] ?? []);
        existing.addAll(seats);
        showtimes[idx]['bookedSeats'] = existing;

        tx.update(movieRef, {'showtimes': showtimes});
      });
    } catch (_) {
      // Non-critical — ticket already saved
    }
  }

  // ── Map Firestore document → Booking entity ────────────────────────
  Booking _bookingFromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      movieId: d['movieId'] as String? ?? '',
      movieTitle: d['movieTitle'] as String? ?? '',
      posterUrl: d['posterUrl'] as String? ?? '',
      showtimeId: d['showtimeId'] as String? ?? '',
      cinemaName: d['cinemaName'] as String? ?? '',
      dateTime: d['dateTime'] is Timestamp
          ? (d['dateTime'] as Timestamp).toDate()
          : DateTime.parse(d['dateTime'] as String),
      selectedSeats: List<String>.from(d['selectedSeats'] ?? []),
      totalPrice: (d['totalPrice'] as num?)?.toDouble() ?? 0.0,
      userId: d['userId'] as String? ?? '',
      bookedAt: d['bookedAt'] is Timestamp
          ? (d['bookedAt'] as Timestamp).toDate()
          : DateTime.parse(d['bookedAt'] as String),
    );
  }

  // ── Booking entity → Firestore map ────────────────────────────────
  Map<String, dynamic> _bookingToMap(Booking b) => {
        'movieId': b.movieId,
        'movieTitle': b.movieTitle,
        'posterUrl': b.posterUrl,
        'showtimeId': b.showtimeId,
        'cinemaName': b.cinemaName,
        'dateTime': Timestamp.fromDate(b.dateTime),
        'selectedSeats': b.selectedSeats,
        'totalPrice': b.totalPrice,
        'userId': b.userId,
        'bookedAt': Timestamp.fromDate(b.bookedAt),
      };

  // ── Local SharedPreferences cache (offline fallback) ───────────────
  Future<List<Booking>> _getLocalBookings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('bookings_$userId') ?? [];
    return raw.map((s) => _bookingFromJson(jsonDecode(s))).toList();
  }

  Future<void> _saveLocalBooking(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'bookings_${booking.userId}';
    final raw = prefs.getStringList(key) ?? [];
    raw.add(jsonEncode(_bookingToJsonLocal(booking)));
    await prefs.setStringList(key, raw);
  }

  Map<String, dynamic> _bookingToJsonLocal(Booking b) => {
        'id': b.id,
        'movieId': b.movieId,
        'movieTitle': b.movieTitle,
        'posterUrl': b.posterUrl,
        'showtimeId': b.showtimeId,
        'cinemaName': b.cinemaName,
        'dateTime': b.dateTime.toIso8601String(),
        'selectedSeats': b.selectedSeats,
        'totalPrice': b.totalPrice,
        'userId': b.userId,
        'bookedAt': b.bookedAt.toIso8601String(),
      };

  Booking _bookingFromJson(Map<String, dynamic> j) => Booking(
        id: j['id'],
        movieId: j['movieId'],
        movieTitle: j['movieTitle'],
        posterUrl: j['posterUrl'],
        showtimeId: j['showtimeId'],
        cinemaName: j['cinemaName'],
        dateTime: DateTime.parse(j['dateTime']),
        selectedSeats: List<String>.from(j['selectedSeats']),
        totalPrice: (j['totalPrice'] as num).toDouble(),
        userId: j['userId'],
        bookedAt: DateTime.parse(j['bookedAt']),
      );
}
