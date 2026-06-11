import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/booking_bloc.dart';
import '../blocs/locale_bloc.dart';
import '../../domain/entities/booking.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BookingBloc>().add(LoadMyBookings());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleBloc>().state.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.myTickets),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: locale == 'de' ? 'Bevorstehend' : 'Upcoming'),
            Tab(text: locale == 'de' ? 'Vergangen' : 'Past'),
          ],
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is MyBookingsLoaded) {
            final now = DateTime.now();
            final upcoming = state.bookings
                .where((b) => b.dateTime.isAfter(now))
                .toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
            final past = state.bookings
                .where((b) => b.dateTime.isBefore(now))
                .toList()
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

            return TabBarView(
              controller: _tabController,
              children: [
                _TicketList(bookings: upcoming, l10n: l10n, locale: locale),
                _TicketList(
                    bookings: past, l10n: l10n, locale: locale, isPast: true),
              ],
            );
          }

          return _EmptyTickets(l10n: l10n);
        },
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  final List<Booking> bookings;
  final AppLocalizations l10n;
  final String locale;
  final bool isPast;

  const _TicketList({
    required this.bookings,
    required this.l10n,
    required this.locale,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _EmptyTickets(l10n: l10n);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _TicketCard(
          booking: bookings[index],
          locale: locale,
          isPast: isPast,
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Booking booking;
  final String locale;
  final bool isPast;

  const _TicketCard({
    required this.booking,
    required this.locale,
    this.isPast = false,
  });

  String _formatDate(DateTime dt) {
    final weekdays = locale == 'de'
        ? ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = locale == 'de'
        ? ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: isPast
              ? AppColors.cardBorder
              : AppColors.primary.withOpacity(0.3),
          width: isPast ? 0.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Top row: poster + info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ColorFiltered(
                    colorFilter: isPast
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ])
                        : const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply),
                    child: Image.network(
                      booking.posterUrl,
                      width: 72,
                      height: 102,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 102,
                        color: AppColors.surface,
                        child: const Icon(Icons.movie_outlined,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPast
                              ? AppColors.surface
                              : AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPast
                              ? (locale == 'de' ? 'Abgelaufen' : 'Expired')
                              : (locale == 'de' ? 'Bestätigt ✓' : 'Confirmed ✓'),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPast
                                ? AppColors.textMuted
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        booking.movieTitle,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _DetailRow(
                          icon: Icons.location_on_outlined,
                          text: booking.cinemaName),
                      const SizedBox(height: 4),
                      _DetailRow(
                          icon: Icons.calendar_today_rounded,
                          text: _formatDate(booking.dateTime)),
                      const SizedBox(height: 4),
                      _DetailRow(
                          icon: Icons.access_time_rounded,
                          text:
                              '${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashed divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(
                40,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    color: i % 2 == 0
                        ? AppColors.cardBorder
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // Bottom row: seats + price + booking ID
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Seats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale == 'de' ? 'Plätze' : 'Seats',
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontFamily: 'Poppins'),
                      ),
                      Text(
                        booking.selectedSeats.join(', '),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      locale == 'de' ? 'Gesamt' : 'Total',
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontFamily: 'Poppins'),
                    ),
                    Text(
                      '€${booking.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isPast ? AppColors.textSecondary : AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 12),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyTickets extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyTickets({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.confirmation_number_outlined,
              color: AppColors.textMuted, size: 72),
          const SizedBox(height: 16),
          Text(
            l10n.noTickets,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppConstants.routeHome),
              child: Text(l10n.goHome),
            ),
          ),
        ],
      ),
    );
  }
}
