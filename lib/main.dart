import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ChainReactionApp());
}

class ChainReactionApp extends StatelessWidget {
  const ChainReactionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chain Reaction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF0F0F23),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935),
          secondary: Color(0xFF1E88E5),
          surface: Color(0xFF1A1A2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
