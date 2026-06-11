import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/movie.dart';
import '../../data/repositories/movie_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class MovieEvent extends Equatable {
  const MovieEvent();
  @override
  List<Object?> get props => [];
}

class LoadMovies extends MovieEvent {
  final String filter;
  const LoadMovies({this.filter = 'all'});
  @override
  List<Object?> get props => [filter];
}

class SearchMovies extends MovieEvent {
  final String query;
  const SearchMovies(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterMovies extends MovieEvent {
  final String filter;
  const FilterMovies(this.filter);
  @override
  List<Object?> get props => [filter];
}

class LoadMovieDetail extends MovieEvent {
  final String movieId;
  const LoadMovieDetail(this.movieId);
  @override
  List<Object?> get props => [movieId];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class MovieState extends Equatable {
  const MovieState();
  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;
  final List<Movie> featured;
  final List<Movie> german;
  final List<Movie> international;
  final String activeFilter;

  const MovieLoaded({
    required this.movies,
    required this.featured,
    required this.german,
    required this.international,
    this.activeFilter = 'all',
  });

  List<Movie> get filtered {
    switch (activeFilter) {
      case 'german':
        return german;
      case 'international':
        return international;
      default:
        return movies;
    }
  }

  MovieLoaded copyWith({
    List<Movie>? movies,
    List<Movie>? featured,
    List<Movie>? german,
    List<Movie>? international,
    String? activeFilter,
  }) {
    return MovieLoaded(
      movies: movies ?? this.movies,
      featured: featured ?? this.featured,
      german: german ?? this.german,
      international: international ?? this.international,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [movies, featured, activeFilter];
}

class MovieSearchResults extends MovieState {
  final List<Movie> results;
  final String query;
  const MovieSearchResults({required this.results, required this.query});
  @override
  List<Object?> get props => [results, query];
}

class MovieDetailLoaded extends MovieState {
  final Movie movie;
  const MovieDetailLoaded(this.movie);
  @override
  List<Object?> get props => [movie];
}

class MovieError extends MovieState {
  final String message;
  const MovieError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository _repository;

  MovieBloc(this._repository) : super(MovieInitial()) {
    on<LoadMovies>(_onLoadMovies);
    on<SearchMovies>(_onSearchMovies);
    on<FilterMovies>(_onFilterMovies);
    on<LoadMovieDetail>(_onLoadMovieDetail);
  }

  void _onLoadMovies(LoadMovies event, Emitter<MovieState> emit) {
    emit(MovieLoading());
    try {
      final all = _repository.getAllMovies();
      final featured = _repository.getFeaturedMovies();
      final german = _repository.getGermanMovies();
      final international = _repository.getInternationalMovies();
      emit(MovieLoaded(
        movies: all,
        featured: featured,
        german: german,
        international: international,
        activeFilter: event.filter,
      ));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  void _onSearchMovies(SearchMovies event, Emitter<MovieState> emit) {
    if (event.query.isEmpty) {
      add(const LoadMovies());
      return;
    }
    try {
      final results = _repository.searchMovies(event.query);
      emit(MovieSearchResults(results: results, query: event.query));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  void _onFilterMovies(FilterMovies event, Emitter<MovieState> emit) {
    if (state is MovieLoaded) {
      final current = state as MovieLoaded;
      emit(current.copyWith(activeFilter: event.filter));
    }
  }

  void _onLoadMovieDetail(LoadMovieDetail event, Emitter<MovieState> emit) {
    try {
      final movie = _repository.getMovieById(event.movieId);
      if (movie != null) {
        emit(MovieDetailLoaded(movie));
      } else {
        emit(const MovieError('Movie not found'));
      }
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }
}
