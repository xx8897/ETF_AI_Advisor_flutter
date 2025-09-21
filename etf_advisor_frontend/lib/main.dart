import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // --- Custom VS Code-like Dark Theme ---
  static final ThemeData vsCodeDarkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6A459A),
      secondary: Color(0xFFCE9178),
      surface: Color(0xFF252526),
      background: Color(0xFF1E1E1E),
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFD4D4D4),
      onBackground: Color(0xFFD4D4D4),
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF333333),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF252526),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF37373D),
      selectedColor: const Color(0xFF6A459A),
      labelStyle: const TextStyle(color: Color(0xFFD4D4D4)),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.all(8),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6A459A),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFFD4D4D4)),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFFD4D4D4)),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xFFD4D4D4)),
      bodyMedium: TextStyle(color: Color(0xFFD4D4D4)),
    ),
    useMaterial3: true,
  );

  // --- Custom Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      accentColor: Colors.orangeAccent,
      brightness: Brightness.light,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETF AI Advisor',
      theme: lightTheme,
      darkTheme: vsCodeDarkTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: const AdvisorHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}