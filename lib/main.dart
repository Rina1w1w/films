import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'bloc/movie_cubit.dart';
import 'bloc/movie_state.dart';
import 'models/movie.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(MovieAdapter());
  }

  final moviesBox = await Hive.openBox<Movie>('movies');

  runApp(MyApp(moviesBox: moviesBox));
}

class MyApp extends StatelessWidget {
  final Box<Movie> moviesBox;

  const MyApp({
    super.key,
    required this.moviesBox,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieCubit(moviesBox: moviesBox),
      child: BlocBuilder<MovieCubit, MovieState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Любимые фильмы',
            theme: state.isDarkTheme
                ? ThemeData.dark()
                : ThemeData.light(),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
