import 'dart:io';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/movie.dart';

class AddEditMoviePage extends StatefulWidget {
  final Movie? movie;
  final int? index;

  const AddEditMoviePage({this.movie, this.index, super.key});

  @override
  State<AddEditMoviePage> createState() => _AddEditMoviePageState();
}

class _AddEditMoviePageState extends State<AddEditMoviePage> {
  final titleCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  String genre = 'Драма';
  String? _imageBase64; 

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      titleCtrl.text = widget.movie!.title;
      yearCtrl.text = widget.movie!.year.toString();
      genre = widget.movie!.genre;
      _imageBase64 = widget.movie!.imagePath;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = _getMimeType(image.name);
      setState(() {
        _imageBase64 = 'data:image/$mimeType;base64,$base64String';
      });
    }
  }

  String _getMimeType(String filename) {
    if (filename.toLowerCase().endsWith('.png')) return 'png';
    if (filename.toLowerCase().endsWith('.jpg')  
        filename.toLowerCase().endsWith('.jpeg')) return 'jpeg';
    if (filename.toLowerCase().endsWith('.gif')) return 'gif';
    return 'jpeg'; 
  }

  Widget _buildImageWidget() {
    if (_imageBase64 == null) {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[300],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo, size: 40),
            SizedBox(height: 8),
            Text('Нет картинки', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }
    
    if (_imageBase64!.startsWith('data:image')) {
      try {
        final base64Data = _imageBase64!.split(',')[1];
        return Image.memory(
          base64Decode(base64Data),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          width: 120,
          height: 120,
          color: Colors.red[100],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 40),
              SizedBox(height: 8),
              Text('Ошибка картинки', style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }
    } else {
      try {
        return Image.file(
          File(_imageBase64!),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 120,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40),
            );
          },
        );
      } catch (e) {
        return Container(
          width: 120,
          height: 120,
          color: Colors.grey[300],
          child: const Icon(Icons.photo, size: 40),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Фильм')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
              ),
            TextField(
              controller: yearCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Год'),
            ),
            DropdownButton<String>(
              value: genre,
              items: ['Драма', 'Комедия', 'Боевик', 'Ужасы', 'Романтика']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => genre = v!),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Выбрать картинку'),
            ),
            const SizedBox(height: 10),
            _buildImageWidget(),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty  yearCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заполните все поля')),
                  );
                  return;
                }
                
                Navigator.pop(
                  context,
                  Movie(
                    title: titleCtrl.text,
                    year: int.parse(yearCtrl.text),
                    genre: genre,
                    imagePath: _imageBase64,
                  ),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
