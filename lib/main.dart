import 'package:flutter/material.dart';
import 'screens/image_merger_screen.dart';

void main() {
  runApp(const ImageMergerApp());
}

class ImageMergerApp extends StatelessWidget {
  const ImageMergerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Merger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ImageMergerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
