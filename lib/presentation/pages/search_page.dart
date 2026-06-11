import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/movie_bloc.dart';
import '../blocs/locale_bloc.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load all movies as default results
    context.read<MovieBloc>().add(const LoadMovies());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleBloc>().state.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          autofocus: true,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (q) {
            context.read<MovieBloc>().add(SearchMovies(q));
          },
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
              onPressed: () {
                _ctrl.clear();
                context.read<MovieBloc>().add(const SearchMovies(''));
                _focus.requestFocus();
              },
            ),
        ],
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.52,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: 9,
              itemBuilder: (_, __) => const ShimmerCard(),
            );
          }

          List movies = [];
          String? query;

          if (state is MovieSearchResults) {
            movies = state.results;
            query = state.query;
          } else if (state is MovieLoaded) {
            movies = state.movies;
          }

          if (movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded,
                      color: AppColors.textMuted, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    query != null
                        ? '${l10n.noMoviesFound}\n"$query"'
                        : l10n.noMoviesFound,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result count
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingM, 8, AppConstants.paddingM, 4,
                ),
                child: Text(
                  '${movies.length} ${locale == 'de' ? 'Ergebnisse' : 'results'}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(
                      movie: movie,
                      locale: locale,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/movie/${movie.id}',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
