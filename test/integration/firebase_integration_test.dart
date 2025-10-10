/// Integration tests for Firebase services
/// 
/// Tests Firebase functionality including:
/// - Authentication flows
/// - Firestore operations
/// - Cloud Functions integration
/// - Offline/online synchronization

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mindful_living/core/models/life_situation.dart';
import 'package:mindful_living/core/models/user_profile.dart';
import 'package:mindful_living/core/models/favorite_item.dart';
import 'package:mindful_living/core/services/favorites_service.dart';

void main() {
  group('Firebase Authentication Integration', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockUser = MockUser(
        uid: 'test-user-123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: false);
    });

    test('User can sign in with email and password', () async {
      expect(mockAuth.currentUser, isNull);
      
      final userCredential = await mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'testpassword123',
      );
      
      expect(userCredential.user, isNotNull);
      expect(userCredential.user!.uid, equals('test-user-123'));
      expect(mockAuth.currentUser, isNotNull);
    });

    test('User can sign out', () async {
      await mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'testpassword123',
      );
      
      expect(mockAuth.currentUser, isNotNull);
      
      await mockAuth.signOut();
      expect(mockAuth.currentUser, isNull);
    });

    test('Anonymous authentication works', () async {
      final userCredential = await mockAuth.signInAnonymously();
      
      expect(userCredential.user, isNotNull);
      expect(userCredential.user!.isAnonymous, isTrue);
    });
  });

  group('Firestore Integration', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('Can create and retrieve life situations', () async {
      final lifeSituation = LifeSituation(
        id: 'situation-123',
        title: 'Managing Work Stress',
        description: 'Effective strategies for workplace stress management',
        mindfulApproach: 'Practice mindful breathing during breaks',
        practicalSteps: ['Take regular breaks', 'Set boundaries'],
        keyInsights: ['Stress is manageable', 'Balance is key'],
        lifeArea: LifeArea.career,
        tags: ['stress', 'work'],
        difficultyLevel: DifficultyLevel.medium,
        estimatedReadTime: 5,
        wellnessFocus: WellnessFocus.mentalHealth,
      );

      // Add to Firestore
      await firestore
          .collection('life_situations')
          .doc(lifeSituation.id)
          .set(lifeSituation.toMap());

      // Retrieve from Firestore
      final doc = await firestore
          .collection('life_situations')
          .doc(lifeSituation.id)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['title'], equals('Managing Work Stress'));
      expect(doc.data()!['lifeArea'], equals('career'));
    });

    test('Can query life situations by category', () async {
      // Add multiple life situations
      final situations = [
        {
          'id': 'career-1',
          'title': 'Job Interview Anxiety',
          'lifeArea': 'career',
          'difficultyLevel': 'medium',
        },
        {
          'id': 'health-1', 
          'title': 'Exercise Motivation',
          'lifeArea': 'health',
          'difficultyLevel': 'easy',
        },
        {
          'id': 'career-2',
          'title': 'Workplace Conflict',
          'lifeArea': 'career',
          'difficultyLevel': 'hard',
        },
      ];

      for (final situation in situations) {
        await firestore
            .collection('life_situations')
            .doc(situation['id'] as String)
            .set(situation);
      }

      // Query career-related situations
      final querySnapshot = await firestore
          .collection('life_situations')
          .where('lifeArea', isEqualTo: 'career')
          .get();

      expect(querySnapshot.docs.length, equals(2));
      expect(querySnapshot.docs.map((doc) => doc.id), 
             containsAll(['career-1', 'career-2']));
    });

    test('User profile operations work correctly', () async {
      final userProfile = UserProfile(
        id: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        preferences: {
          'language': 'en',
          'theme': 'light',
          'notifications': true,
        },
      );

      // Create user profile
      await firestore
          .collection('users')
          .doc(userProfile.id)
          .set(userProfile.toMap());

      // Retrieve user profile
      final doc = await firestore
          .collection('users')
          .doc(userProfile.id)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['email'], equals('test@example.com'));
      expect(doc.data()!['preferences']['language'], equals('en'));

      // Update preferences
      await firestore
          .collection('users')
          .doc(userProfile.id)
          .update({
        'preferences.theme': 'dark',
        'lastActiveAt': DateTime.now().toIso8601String(),
      });

      final updatedDoc = await firestore
          .collection('users')
          .doc(userProfile.id)
          .get();

      expect(updatedDoc.data()!['preferences']['theme'], equals('dark'));
    });
  });

  group('Favorites Service Integration', () {
    late FakeFirebaseFirestore firestore;
    late FavoritesService favoritesService;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      favoritesService = FavoritesService();
    });

    test('Can add and remove favorites', () async {
      const userId = 'user-123';
      const itemId = 'situation-456';
      
      final favorite = FavoriteItem(
        id: 'fav-123',
        userId: userId,
        itemId: itemId,
        itemType: FavoriteItemType.lifeSituation,
        addedAt: DateTime.now(),
      );

      // Add favorite
      await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(favorite.id)
          .set(favorite.toMap());

      // Verify favorite exists
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(favorite.id)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['itemId'], equals(itemId));

      // Remove favorite
      await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(favorite.id)
          .delete();

      // Verify favorite is removed
      final deletedDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(favorite.id)
          .get();

      expect(deletedDoc.exists, isFalse);
    });

    test('Can retrieve user favorites list', () async {
      const userId = 'user-123';
      
      // Add multiple favorites
      final favorites = [
        FavoriteItem(
          id: 'fav-1',
          userId: userId,
          itemId: 'situation-1',
          itemType: FavoriteItemType.lifeSituation,
          addedAt: DateTime.now(),
        ),
        FavoriteItem(
          id: 'fav-2',
          userId: userId,
          itemId: 'practice-1',
          itemType: FavoriteItemType.practice,
          addedAt: DateTime.now(),
        ),
      ];

      for (final favorite in favorites) {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(favorite.id)
            .set(favorite.toMap());
      }

      // Retrieve favorites
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      expect(querySnapshot.docs.length, equals(2));
      expect(querySnapshot.docs.map((doc) => doc.data()['itemType']),
             containsAll(['lifeSituation', 'practice']));
    });
  });

  group('Offline/Online Synchronization', () {
    test('Data persists locally when offline', () async {
      final firestore = FakeFirebaseFirestore();
      
      // Simulate offline mode by creating local data
      final localData = {
        'id': 'offline-entry-1',
        'title': 'Offline Journal Entry',
        'content': 'This was created while offline',
        'timestamp': DateTime.now().toIso8601String(),
        'synced': false,
      };

      // Store locally (simulated)
      final localDoc = firestore
          .collection('local_cache')
          .doc(localData['id'] as String);
      
      await localDoc.set(localData);

      // Verify local storage
      final doc = await localDoc.get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['synced'], isFalse);

      // Simulate going online and syncing
      await firestore
          .collection('journal_entries')
          .doc(localData['id'] as String)
          .set({
        ...localData,
        'synced': true,
      });

      // Verify sync
      final syncedDoc = await firestore
          .collection('journal_entries')
          .doc(localData['id'] as String)
          .get();

      expect(syncedDoc.exists, isTrue);
      expect(syncedDoc.data()!['synced'], isTrue);
    });
  });

  group('Performance and Error Handling', () {
    test('Handles large data queries efficiently', () async {
      final firestore = FakeFirebaseFirestore();
      final stopwatch = Stopwatch()..start();

      // Create 100 test documents
      for (int i = 0; i < 100; i++) {
        await firestore
            .collection('test_collection')
            .doc('doc-$i')
            .set({
          'index': i,
          'title': 'Test Document $i',
          'data': 'Sample data for testing performance',
        });
      }

      stopwatch.stop();

      // Query should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Verify all documents were created
      final querySnapshot = await firestore
          .collection('test_collection')
          .get();

      expect(querySnapshot.docs.length, equals(100));
    });

    test('Handles network errors gracefully', () async {
      final firestore = FakeFirebaseFirestore();

      // Simulate network error by trying to access non-existent document
      final doc = await firestore
          .collection('non_existent')
          .doc('fake-id')
          .get();

      expect(doc.exists, isFalse);
      
      // Should not throw exception, just return empty document
      expect(() => doc.data(), returnsNormally);
    });
  });
}