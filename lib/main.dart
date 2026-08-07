import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'database_service.dart';
import 'app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseService();
  await db.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(db)..load(),
      child: const DigitalKhataApp(),
    ),
  );
}
