import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'features/auth/data/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    // Firebase already initialized - this is okay for hot reload
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized');
    } else {
      print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize AuthService
  final authService = AuthService();
  await authService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
      ],
      child: const MindfulLivingApp(),
    ),
  );
}
