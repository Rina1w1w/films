import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/movie.dart';
import '../bloc/movie_cubit.dart';
import '../bloc/movie_state.dart';
import 'add_edit_movie_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _getMovieImage(Movie movie) {
    if (movie.imagePath == null) {
      return Container(
        width: 50,
        height: 50,
        color: Colors.grey[300],
        child: const Icon(Icons.movie, size: 30),
      );
    }

    try {
      final base64Data = movie.imagePath!.split(',')[1];
      return Image.memory(
        base64Decode(base64Data),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Container(
        width: 50,
        height: 50,
        color: Colors.grey[300],
        child: const Icon(Icons.error, size: 30),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Любимые фильмы'),
        actions: [
          BlocBuilder<MovieCubit, MovieState>(
            builder: (context, state) {
              return Switch(
                value: state.isDarkTheme,
                onChanged: (value) {
                  context.read<MovieCubit>().toggleTheme(value);
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MovieCubit, MovieState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.movies.length,
            itemBuilder: (_, index) {
              final movie = state.movies[index];
              return ListTile(
                leading: _getMovieImage(movie),
                title: Text(movie.title),
                subtitle: Text('${movie.year} • ${movie.genre}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<MovieCubit>().deleteMovie(index);
                  },
                ),
                onTap: () async {
                  final updated = await Navigator.push<Movie>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditMoviePage(
                        movie: movie,
                        index: index,
                      ),
                    ),
                  );
                  if (updated != null) {
                    context.read<MovieCubit>().updateMovie(index, updated);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final movie = await Navigator.push<Movie>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditMoviePage(),
            ),
          );
          if (movie != null) {
            context.read<MovieCubit>().addMovie(movie);
          }
        },
      ),
    );
  }
}
