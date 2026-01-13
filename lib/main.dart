import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importa il file della home

void main() {
  runApp(const AnimeUnoApp());
}

class AnimeUnoApp extends StatelessWidget {
  const AnimeUnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const HomeScreen(),
    );
  }
}