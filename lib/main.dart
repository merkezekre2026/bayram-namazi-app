import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/location_selection_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/qibla_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasLocation = prefs.getString('district_id') != null;

  runApp(BayramNamaziApp(initialRoute: hasLocation ? '/' : '/location'));
}

class BayramNamaziApp extends StatelessWidget {
  final String initialRoute;

  const BayramNamaziApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bayram Namazı Saatleri',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF071B15), // Deep dark green slate
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0F4C3A), // Emerald Green
          secondary: Color(0xFFD4AF37), // Metallic Gold
          surface: Color(0xFF0D2D23), // Dark Teal/Green Card
          background: Color(0xFF071B15),
          onPrimary: Colors.white,
          onSecondary: Color(0xFF071B15),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF071B15),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF0D2D23),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0x33D4AF37), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF071B15),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/location': (context) => const LocationSelectionScreen(),
        '/guide': (context) => const GuideScreen(),
        '/qibla': (context) => const QiblaScreen(),
      },
    );
  }
}
