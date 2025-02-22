import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/providers/game_provider.dart';
import 'view/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AdMob servisini başlat
  await MobileAds.instance.initialize();

  runApp(
    // Provider ile state management yapısını kur
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          secondary: const Color(0xFF00C4B4),
          brightness: Brightness.light,
          primary: const Color.fromARGB(255, 107, 27, 218),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFF2E7FE),
          onPrimaryContainer: const Color(0xFF3700B3),
          secondaryContainer: const Color(0xFFE3F2FD),
          onSecondaryContainer: const Color(0xFF1565C0),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
