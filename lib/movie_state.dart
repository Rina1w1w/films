import '../models/movie.dart';

class MovieState {
  final List<Movie> movies;
  final bool isDarkTheme;

  MovieState({
    required this.movies,
    required this.isDarkTheme,
  });

  factory MovieState.initial() {
    return MovieState(
      movies: [],
      isDarkTheme: false,
    );
  }

  MovieState copyWith({
    List<Movie>? movies,
    bool? isDarkTheme,
  }) {
    return MovieState(
      movies: movies ?? this.movies,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
    );
  }
}
