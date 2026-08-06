import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: OkBookApp()));
}

class OkBookApp extends StatelessWidget {
  const OkBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OK Book',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
