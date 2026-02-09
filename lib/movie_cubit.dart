import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  final Box<Movie> _moviesBox;

  MovieCubit({required Box<Movie> moviesBox})
      : _moviesBox = moviesBox,
        super(MovieState.initial()) {
    _init();
  }
  
  Future<void> _init() async {
    await _loadMovies();
    await _loadTheme();
  }

  Future<void> _loadMovies() async {
    final movies = _moviesBox.values.toList();
    emit(state.copyWith(movies: movies));
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('darkTheme') ?? false;
    emit(state.copyWith(isDarkTheme: isDark));
  }

  Future<void> addMovie(Movie movie) async {
    await _moviesBox.add(movie);
    await _loadMovies();
  }

  Future<void> deleteMovie(int index) async {
    await _moviesBox.deleteAt(index);
    await _loadMovies();
  }

  Future<void> updateMovie(int index, Movie movie) async {
    await _moviesBox.putAt(index, movie);
    await _loadMovies();
  }

  
  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', isDark);
    emit(state.copyWith(isDarkTheme: isDark));
  }
}
