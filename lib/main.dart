import 'package:flutter/material.dart';
import 'screens/landing_screen.dart'; // Import landing screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeHija',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        fontFamily: 'Nunito', // Atau font utama aplikasi Anda
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE89838)), // kPrimaryColor
        useMaterial3: true,
      ),
      // Ubah dari DrawingScreen() menjadi LandingScreen()
      home: const LandingScreen(), 
    );
  }
}