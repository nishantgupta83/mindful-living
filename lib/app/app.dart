import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/pastel_theme.dart';
// import '../core/android/android_initialization.dart';
// import '../core/android/android_material_design.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../test_firebase.dart'; // Firebase test screen
import '../generated/l10n/app_localizations.dart';
import 'dart:io' show Platform;

class MindfulLivingApp extends StatefulWidget {
  const MindfulLivingApp({super.key});

  @override
  State<MindfulLivingApp> createState() => _MindfulLivingAppState();
}

class _MindfulLivingAppState extends State<MindfulLivingApp> {
  ThemeData? _androidLightTheme;
  ThemeData? _androidDarkTheme;
  bool _androidInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAndroidOptimizations();
  }

  Future<void> _initializeAndroidOptimizations() async {
    if (Platform.isAndroid) {
      try {
        // Android-specific optimizations temporarily disabled for build fix
        // Initialize Android-specific optimizations
        // WidgetsBinding.instance.addPostFrameCallback((_) async {
        //   await AndroidInitializationManager.initialize(context);

        //   // Get Android-optimized themes
        //   final lightTheme = await AndroidMaterialDesign.getDynamicWellnessTheme(dark: false);
        //   final darkTheme = await AndroidMaterialDesign.getDynamicWellnessTheme(dark: true);

        //   if (mounted) {
        //     setState(() {
        //       _androidLightTheme = lightTheme;
        //       _androidDarkTheme = darkTheme;
        //       _androidInitialized = true;
        //     });
        //   }
        // });
      } catch (e) {
        debugPrint('Android optimization initialization failed: $e');
      }
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      // AndroidInitializationManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Android-optimized themes if available, fallback to pastel themes
    final lightTheme = Platform.isAndroid && _androidLightTheme != null
        ? _androidLightTheme!
        : PastelTheme.lightTheme;

    final darkTheme = Platform.isAndroid && _androidDarkTheme != null
        ? _androidDarkTheme!
        : PastelTheme.darkTheme;

    return MaterialApp(
      title: 'Mindful Living',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const AndroidOptimizedWrapper(
        child: DashboardScreen(), // Main app dashboard
      ),

      // Localization settings
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('es', 'ES'), // Spanish
        Locale('hi', 'IN'), // Hindi
      ],

      // Material 3 design with Android optimizations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Wrapper widget that applies Android-specific optimizations
class AndroidOptimizedWrapper extends StatefulWidget {
  final Widget child;

  const AndroidOptimizedWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AndroidOptimizedWrapper> createState() => _AndroidOptimizedWrapperState();
}

class _AndroidOptimizedWrapperState extends State<AndroidOptimizedWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Platform.isAndroid) {
      // Configure system UI for current theme
      final brightness = Theme.of(context).brightness;
      final isDarkMode = brightness == Brightness.dark;

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDarkMode
              ? const Color(0xFF1C1B1F)
              : Colors.white,
          systemNavigationBarIconBrightness: isDarkMode
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );

      // Enable edge-to-edge display for Android
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}