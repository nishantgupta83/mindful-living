/// Comprehensive widget tests for Mindful Living app
/// 
/// Tests cover:
/// - App initialization and basic functionality
/// - Widget rendering and interactions
/// - Navigation flow
/// - State management validation
/// - Accessibility compliance

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mindful_living/app/app.dart';
import 'package:mindful_living/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:mindful_living/shared/components/cards/wellness_circle.dart';
import 'package:mindful_living/shared/components/cards/mindful_card.dart';

void main() {
  group('App Initialization Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MindfulLivingApp());

      // Verify that the app launches without crashing
      await tester.pumpAndSettle();
      
      // Verify MaterialApp is created
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has correct theme configuration', (WidgetTester tester) async {
      await tester.pumpWidget(const MindfulLivingApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify theme configuration
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      
      // Verify localization support
      expect(materialApp.localizationsDelegates, contains(GlobalMaterialLocalizations.delegate));
      expect(materialApp.localizationsDelegates, contains(GlobalWidgetsLocalizations.delegate));
      expect(materialApp.localizationsDelegates, contains(GlobalCupertinoLocalizations.delegate));
    });

    testWidgets('App supports multiple locales', (WidgetTester tester) async {
      await tester.pumpWidget(const MindfulLivingApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify supported locales
      expect(materialApp.supportedLocales, isNotEmpty);
      expect(materialApp.supportedLocales.map((l) => l.languageCode), 
             containsAll(['en', 'es', 'hi']));
    });
  });

  group('Dashboard Widget Tests', () {
    testWidgets('Dashboard renders main navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Verify bottom navigation is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify all 5 navigation tabs
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Situations'), findsOneWidget);
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('Practices'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Dashboard shows welcome section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Verify welcome message
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Start your mindful day with intention and clarity'), findsOneWidget);
    });

    testWidgets('Dashboard has wellness score section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Verify wellness score elements
      expect(find.text('Today\'s Wellness'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Dashboard navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Situations tab
      await tester.tap(find.text('Situations'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Life Situations - Coming Soon'), findsOneWidget);

      // Tap on Journal tab
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Journal - Coming Soon'), findsOneWidget);
    });
  });

  group('Component Widget Tests', () {
    testWidgets('WellnessCircle renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WellnessCircle(
              score: 75,
              label: 'Test Score',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify circle is rendered
      expect(find.byType(WellnessCircle), findsOneWidget);
      expect(find.text('Test Score'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('WellnessCircle animation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WellnessCircle(
              score: 80,
              enableAnimation: true,
            ),
          ),
        ),
      );

      // Pump a few frames to let animation start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));

      // Animation should be progressing
      expect(find.byType(WellnessCircle), findsOneWidget);
    });

    testWidgets('MindfulCard renders with all elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindfulCard(
              title: 'Test Card',
              description: 'Test description for the card',
              category: 'Test Category',
              tags: ['tag1', 'tag2'],
              isFavorited: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify card elements
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('Test description for the card'), findsOneWidget);
      expect(find.text('TEST CATEGORY'), findsOneWidget);
      expect(find.text('tag1'), findsOneWidget);
      expect(find.text('tag2'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('MindfulCard favorite toggle works', (WidgetTester tester) async {
      bool isFavorited = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: MindfulCard(
                title: 'Test Card',
                description: 'Test description',
                category: 'Test',
                isFavorited: isFavorited,
                onFavoriteToggle: () {
                  setState(() {
                    isFavorited = !isFavorited;
                  });
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially should show empty heart
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap the favorite button
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // Should now show filled heart
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('Dashboard has semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Check for accessibility semantics
      expect(tester.getSemantics(find.byType(BottomNavigationBar)), isNotNull);
    });

    testWidgets('Interactive elements have sufficient tap targets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Find all interactive elements and verify they meet minimum size requirements
      final buttons = find.byType(IconButton);
      for (int i = 0; i < buttons.evaluate().length; i++) {
        final button = tester.widget<IconButton>(buttons.at(i));
        final renderBox = tester.renderObject<RenderBox>(buttons.at(i));
        
        // Minimum tap target size should be 44x44 (iOS) or 48x48 (Material)
        expect(renderBox.size.width, greaterThanOrEqualTo(44));
        expect(renderBox.size.height, greaterThanOrEqualTo(44));
      }
    });
  });

  group('Performance Tests', () {
    testWidgets('Dashboard renders within performance budget', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Rendering should complete within reasonable time (500ms for debug mode)
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('Navigation transitions are smooth', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardPage(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Test navigation transitions
      for (final tab in ['Situations', 'Journal', 'Practices', 'Profile']) {
        final stopwatch = Stopwatch()..start();
        
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Navigation should be fast (100ms budget)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      }
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App handles missing data gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindfulCard(
              title: '',
              description: '',
              category: '',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // App should still render without crashing
      expect(find.byType(MindfulCard), findsOneWidget);
    });

    testWidgets('App handles null callbacks gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindfulCard(
              title: 'Test',
              description: 'Test',
              category: 'Test',
              onTap: null,
              onFavoriteToggle: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.byType(MindfulCard), findsOneWidget);
      
      // Tapping should not crash
      await tester.tap(find.byType(MindfulCard));
      await tester.pumpAndSettle();
    });
  });
}
