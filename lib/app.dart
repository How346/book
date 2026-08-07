import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'splash_screen.dart';
import 'theme.dart';

class DigitalKhataApp extends StatelessWidget {
  const DigitalKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Khata',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: state.themeMode,
      home: const SplashScreen(),
    );
  }
}
