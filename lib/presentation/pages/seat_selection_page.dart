import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/booking_bloc.dart';
import '../blocs/locale_bloc.dart';
import '../../domain/entities/movie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'booking_confirmation_page.dart';

class SeatSelectionPage extends StatelessWidget {
  final Showtime showtime;
  final Movie movie;

  const SeatSelectionPage({
    super.key,
    required this.showtime,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleBloc>().state.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.selectSeats),
        backgroundColor: AppColors.background,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<BookingBloc>(),
                  child: BookingConfirmationPage(booking: state.booking),
                ),
              ),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final selected = state is BookingShowtimeSelected
              ? state.selectedSeats
              : <String>[];
          final totalPrice = state is BookingShowtimeSelected
              ? state.totalPrice
              : 0.0;
          final isLoading = state is BookingLoading;

          return Column(
            children: [
              // Movie info header
              Container(
                margin: const EdgeInsets.all(AppConstants.paddingM),
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.posterUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 70,
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.localizedTitle(locale),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            showtime.cinemaName,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          Text(
                            '${showtime.dateTime.day}.${showtime.dateTime.month}.${showtime.dateTime.year}  '
                            '${showtime.dateTime.hour.toString().padLeft(2, '0')}:'
                            '${showtime.dateTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                          Text(
                            showtime.hall,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Screen indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.primary.withOpacity(0.6),
                            Colors.transparent
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SCREEN',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        letterSpacing: 3,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Seat grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingM),
                  child: _SeatGrid(
                    bookedSeats: showtime.bookedSeats,
                    selectedSeats: selected,
                    onSeatTap: (seatId) =>
                        context.read<BookingBloc>().add(ToggleSeat(seatId)),
                  ),
                ),
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                        color: AppColors.seatAvailable,
                        label: l10n.available),
                    const SizedBox(width: 20),
                    _LegendItem(
                        color: AppColors.seatSelected, label: l10n.selected),
                    const SizedBox(width: 20),
                    _LegendItem(
                        color: AppColors.seatOccupied, label: l10n.occupied),
                  ],
                ),
              ),

              // Bottom bar
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.cardBorder, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.seats}: ${selected.length}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${l10n.totalPrice}: €${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: (selected.isEmpty || isLoading)
                            ? null
                            : () => context
                                .read<BookingBloc>()
                                .add(ConfirmBooking()),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : Text(l10n.payNow),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SeatGrid extends StatelessWidget {
  final List<String> bookedSeats;
  final List<String> selectedSeats;
  final ValueChanged<String> onSeatTap;

  static const List<String> _rows = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'
  ];
  static const int _seatsPerRow = 10;

  const _SeatGrid({
    required this.bookedSeats,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  row,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_seatsPerRow, (i) {
                    final seatNum = i + 1;
                    final seatId = '$row$seatNum';
                    final isBooked = bookedSeats.contains(seatId);
                    final isSelected = selectedSeats.contains(seatId);

                    // Aisle gap
                    if (i == 4) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SeatWidget(
                            seatId: seatId,
                            isBooked: isBooked,
                            isSelected: isSelected,
                            onTap: onSeatTap,
                          ),
                          const SizedBox(width: 12),
                        ],
                      );
                    }

                    return _SeatWidget(
                      seatId: seatId,
                      isBooked: isBooked,
                      isSelected: isSelected,
                      onTap: onSeatTap,
                    );
                  }),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 20,
                child: Text(
                  row,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SeatWidget extends StatelessWidget {
  final String seatId;
  final bool isBooked;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const _SeatWidget({
    required this.seatId,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    if (isBooked) {
      bg = AppColors.seatOccupied;
      border = AppColors.seatOccupied;
    } else if (isSelected) {
      bg = AppColors.seatSelected;
      border = AppColors.seatSelected;
    } else {
      bg = AppColors.seatAvailable;
      border = AppColors.cardBorder;
    }

    return GestureDetector(
      onTap: isBooked ? null : () => onTap(seatId),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          border: Border.all(color: border, width: 0.5),
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
            : null,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
