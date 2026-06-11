import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/booking_bloc.dart';
import '../../domain/entities/booking.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class BookingConfirmationPage extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            children: [
              const Spacer(),

              // Success animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.5), width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 52),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.bookingConfirmed,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.enjoyMovie,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Ticket card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    // Top section with poster
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              booking.posterUrl,
                              width: 60,
                              height: 85,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 85,
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
                                  booking.movieTitle,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 6),
                                Text(booking.cinemaName,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13)),
                                Text(
                                  '${booking.dateTime.day}.${booking.dateTime.month}.${booking.dateTime.year}  '
                                  '${booking.dateTime.hour.toString().padLeft(2, '0')}:'
                                  '${booking.dateTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dashed separator
                    _DashedDivider(),

                    // Bottom section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TicketDetail(
                                  label: l10n.seats,
                                  value: booking.selectedSeats.join(', ')),
                              _TicketDetail(
                                label: l10n.totalPrice,
                                value:
                                    '€${booking.totalPrice.toStringAsFixed(2)}',
                                isHighlighted: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _TicketDetail(
                            label: l10n.bookingId,
                            value: booking.id.substring(0, 8).toUpperCase(),
                          ),
                        ],
                      ),
                    ),

                    // Barcode placeholder
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          40,
                          (i) => Container(
                            width: i % 3 == 0 ? 3 : 1.5,
                            height: i % 5 == 0 ? 40 : 28,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            color: AppColors.textSecondary
                                .withOpacity(i % 2 == 0 ? 0.8 : 0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  context.read<BookingBloc>().add(ResetBooking());
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppConstants.routeHome, (_) => false);
                },
                child: Text(l10n.goHome),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, 20),
          painter: _DashedLinePainter(),
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cardBorder
      ..strokeWidth = 1;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicketDetail extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _TicketDetail({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontFamily: 'Poppins'),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isHighlighted ? 16 : 13,
            fontWeight: FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
