import 'dart:io';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/movie.dart';
import 'add_edit_movie_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final bool isDark;
  final Function(bool) onThemeChanged;

  const HomePage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box<Movie>('moviesBox');

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
      if (movie.imagePath!.startsWith('data:image')) {
        return Image.memory(
          base64Decode(movie.imagePath!.split(',')[1]),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      }
      
      final file = File(movie.imagePath!);
      return Image.file(
        file,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 30),
          );
        },
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    isDark: widget.isDark,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final movie = await Navigator.push<Movie>(
            context,
            MaterialPageRoute(builder: (_) => const AddEditMoviePage()),
          );
          if (movie != null) {
            box.add(movie);
            setState(() {});
          }
        },
      ),
      body: ListView.builder(
        itemCount: box.length,
        itemBuilder: (_, index) {
          final movie = box.getAt(index)!;
          return ListTile(
            leading: _getMovieImage(movie),
            title: Text(movie.title),
            subtitle: Text('${movie.year} • ${movie.genre}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                box.deleteAt(index);
                setState(() {});
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
                box.putAt(index, updated);
                setState(() {});
              }
            },
          );
        },
      ),
    );
  }
}
