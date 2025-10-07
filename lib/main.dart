import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelEase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Kumbh Sans',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
