import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/movie_bloc.dart';
import '../blocs/locale_bloc.dart';
import '../blocs/booking_bloc.dart' as booking_bloc;
import '../widgets/movie_card.dart';
import '../widgets/featured_banner.dart';
import '../widgets/shimmer_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<MovieBloc>().add(const LoadMovies());
    context.read<booking_bloc.BookingBloc>().add(booking_bloc.LoadMyBookings());
  }

  void _onNavTap(int index) {
    // Tabs 1,2,3 push dedicated pages; tab 0 stays home
    switch (index) {
      case 0:
        setState(() => _selectedTab = 0);
        break;
      case 1:
        Navigator.pushNamed(context, AppConstants.routeSearch);
        break;
      case 2:
        Navigator.pushNamed(context, AppConstants.routeMyTickets);
        break;
      case 3:
        Navigator.pushNamed(context, AppConstants.routeProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleBloc>().state.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _HomeTab(l10n: l10n, locale: locale)),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: _onNavTap,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Poppins', fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_rounded),
              label: locale == 'de' ? 'Suche' : 'Search',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.confirmation_number_outlined),
              label: l10n.myTickets,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final AppLocalizations l10n;
  final String locale;
  const _HomeTab({required this.l10n, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        // Loading skeleton
        if (state is MovieLoading) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: const ShimmerBanner(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const ShimmerCard(),
                    childCount: 6,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                ),
              ),
            ],
          );
        }

        // Error
        if (state is MovieError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text(state.message,
                    style:
                        const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<MovieBloc>().add(const LoadMovies()),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        if (state is! MovieLoaded) return const SizedBox();

        return CustomScrollView(
          slivers: [
            // App bar with logo + language toggle
            SliverToBoxAdapter(child: _buildHeader(context)),

            // Featured carousel
            if (state.featured.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(l10n.featuredMovie,
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 270,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.92),
                    itemCount: state.featured.length,
                    itemBuilder: (context, index) {
                      final movie = state.featured[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FeaturedMovieBanner(
                          movie: movie,
                          locale: locale,
                          onTap: () => Navigator.pushNamed(
                              context, '/movie/${movie.id}'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: l10n.filterAll,
                        isSelected: state.activeFilter == 'all',
                        onTap: () => context
                            .read<MovieBloc>()
                            .add(const FilterMovies('all')),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '🇩🇪  ${l10n.filterGerman}',
                        isSelected: state.activeFilter == 'german',
                        onTap: () => context
                            .read<MovieBloc>()
                            .add(const FilterMovies('german')),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '🌍  ${l10n.filterInternational}',
                        isSelected: state.activeFilter == 'international',
                        onTap: () => context
                            .read<MovieBloc>()
                            .add(const FilterMovies('international')),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.nowShowing,
                        style: Theme.of(context).textTheme.headlineMedium),
                    Text(
                      '${state.filtered.length} ${locale == 'de' ? 'Filme' : 'films'}',
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ),

            // Movie grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final movie = state.filtered[index];
                    return MovieCard(
                      movie: movie,
                      locale: locale,
                      onTap: () => Navigator.pushNamed(
                          context, '/movie/${movie.id}'),
                    );
                  },
                  childCount: state.filtered.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.52,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.movie_filter_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'KinoFlow',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          // Language toggle
          GestureDetector(
            onTap: () {
              final newLocale = locale == 'en' ? 'de' : 'en';
              context.read<LocaleBloc>().add(ChangeLocale(newLocale));
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(locale == 'en' ? '🇬🇧' : '🇩🇪',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    locale == 'en' ? 'EN' : 'DE',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.swap_horiz_rounded,
                      size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
