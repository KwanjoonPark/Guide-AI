import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GuideAIApp());
}

class GuideAIApp extends StatelessWidget {
  const GuideAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guide AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5CC),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
