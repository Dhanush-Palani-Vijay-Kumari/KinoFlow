import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/movie_bloc.dart';
import '../blocs/booking_bloc.dart';
import '../blocs/locale_bloc.dart';
import '../../domain/entities/movie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'seat_selection_page.dart';

class MovieDetailPage extends StatefulWidget {
  final String movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<MovieBloc>().add(LoadMovieDetail(widget.movieId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleBloc>().state.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is MovieDetailLoaded) {
            return _MovieDetailContent(
              movie: state.movie,
              l10n: l10n,
              locale: locale,
            );
          }
          if (state is MovieError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.textSecondary)),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _MovieDetailContent extends StatefulWidget {
  final Movie movie;
  final AppLocalizations l10n;
  final String locale;

  const _MovieDetailContent({
    required this.movie,
    required this.l10n,
    required this.locale,
  });

  @override
  State<_MovieDetailContent> createState() => _MovieDetailContentState();
}

class _MovieDetailContentState extends State<_MovieDetailContent> {
  Showtime? _selectedShowtime;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final l10n = widget.l10n;
    final locale = widget.locale;

    return CustomScrollView(
      slivers: [
        // Hero App Bar
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppColors.background,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  movie.backdropUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.cardBackground),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.heroGradient,
                      stops: [0.2, 0.7, 1.0],
                    ),
                  ),
                ),
                // Poster + quick info overlay
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          movie.posterUrl,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 120,
                            color: AppColors.cardBackground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 4,
                              children: movie.genres
                                  .take(2)
                                  .map((g) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(g,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              movie.localizedTitle(locale),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.gold, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  movie.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.access_time_rounded,
                                    color: Colors.white60, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  '${movie.durationMinutes} min',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info row
                Row(
                  children: [
                    _InfoChip(
                        icon: Icons.language_rounded,
                        label: movie.language),
                    const SizedBox(width: 8),
                    _InfoChip(
                        icon: Icons.calendar_today_rounded,
                        label: movie.releaseDate),
                    const SizedBox(width: 8),
                    if (movie.isGerman)
                      _InfoChip(icon: null, label: '🇩🇪 German Film'),
                  ],
                ),
                const SizedBox(height: 20),

                // Synopsis
                Text(l10n.synopsis,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  movie.localizedSynopsis(locale),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),

                // Director
                Text(l10n.director,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(movie.director,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),

                // Cast
                Text(l10n.cast,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: movie.cast
                        .map((name) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _CastChip(name: name),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Showtimes
                Text(l10n.selectShowtime,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                _ShowtimeSelector(
                  showtimes: movie.showtimes,
                  selectedShowtime: _selectedShowtime,
                  onSelect: (st) => setState(() => _selectedShowtime = st),
                  locale: locale,
                ),
                const SizedBox(height: 28),

                // Book button
                ElevatedButton(
                  onPressed: _selectedShowtime == null
                      ? null
                      : () {
                          context.read<BookingBloc>().add(SelectShowtime(
                                showtime: _selectedShowtime!,
                                movie: movie,
                              ));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<BookingBloc>(),
                                child: SeatSelectionPage(
                                  showtime: _selectedShowtime!,
                                  movie: movie,
                                ),
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedShowtime == null
                        ? AppColors.cardBackground
                        : AppColors.primary,
                  ),
                  child: Text(l10n.bookNow),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  const _InfoChip({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textSecondary, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CastChip extends StatelessWidget {
  final String name;
  const _CastChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withOpacity(0.3),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowtimeSelector extends StatefulWidget {
  final List<Showtime> showtimes;
  final Showtime? selectedShowtime;
  final ValueChanged<Showtime> onSelect;
  final String locale;

  const _ShowtimeSelector({
    required this.showtimes,
    required this.selectedShowtime,
    required this.onSelect,
    required this.locale,
  });

  @override
  State<_ShowtimeSelector> createState() => _ShowtimeSelectorState();
}

class _ShowtimeSelectorState extends State<_ShowtimeSelector> {
  int _selectedDayIndex = 0;

  List<DateTime> get _uniqueDates {
    final dates = widget.showtimes.map((s) {
      final d = s.dateTime;
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList();
    dates.sort();
    return dates;
  }

  List<Showtime> _showtimesForDay(DateTime day) {
    return widget.showtimes.where((s) {
      final d = s.dateTime;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    if (date == today) return widget.locale == 'de' ? 'Heute' : 'Today';
    if (date == tomorrow) return widget.locale == 'de' ? 'Morgen' : 'Tomorrow';
    final weekdays = widget.locale == 'de'
        ? ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dates = _uniqueDates;
    if (dates.isEmpty) return const SizedBox();

    final selectedDay =
        _selectedDayIndex < dates.length ? dates[_selectedDayIndex] : dates[0];
    final showtimes = _showtimesForDay(selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.asMap().entries.map((entry) {
              final isSelected = entry.key == _selectedDayIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = entry.key),
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _dayLabel(entry.value),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${entry.value.day}.${entry.value.month}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white70
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Showtime slots
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: showtimes.map((st) {
            final isSelected = widget.selectedShowtime?.id == st.id;
            return GestureDetector(
              onTap: () => widget.onSelect(st),
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBorder,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${st.dateTime.hour.toString().padLeft(2, '0')}:'
                      '${st.dateTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      st.hall,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted),
                    ),
                    Text(
                      '€${st.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
