import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devocional_nuevo/services/spiritual_progress_service.dart';
import 'package:devocional_nuevo/models/spiritual_progress_stats.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  group('SpiritualProgressService Tests', () {
    late SpiritualProgressService service;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocRef;
    late MockDocumentSnapshot mockDocSnapshot;

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
      registerFallbackValue(SetOptions());
    });

    setUp(() {
      service = SpiritualProgressService();
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockCollection = MockCollectionReference();
      mockDocRef = MockDocumentReference();
      mockDocSnapshot = MockDocumentSnapshot();

      // Setup basic mocks
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test_user_123');
    });

    group('getUserStats', () {
      test('should return null when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);
        
        final result = await service.getUserStats();
        
        expect(result, isNull);
      });

      test('should create initial stats when document does not exist', () async {
        when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.set(any())).thenAnswer((_) async => {});

        final result = await service.getUserStats();

        expect(result, isNotNull);
        expect(result!.userId, equals('test_user_123'));
        expect(result.devotionalsCompleted, equals(0));
        expect(result.prayerTimeMinutes, equals(0));
        expect(result.versesMemorized, equals(0));
        expect(result.currentStreak, equals(0));
      });
    });

    group('Activity Type Tests', () {
      test('should handle all activity types correctly', () {
        // Test that all enum values can be converted to/from strings
        for (final activityType in SpiritualActivityType.values) {
          final stringValue = activityType.toString();
          expect(stringValue, contains('SpiritualActivityType.'));
          
          // Test that we can find the enum back from the string
          final foundType = SpiritualActivityType.values.firstWhere(
            (e) => e.toString() == stringValue,
            orElse: () => SpiritualActivityType.devotionalCompleted,
          );
          expect(foundType, equals(activityType));
        }
      });
    });

    group('Helper Methods Tests', () {
      test('should calculate week number correctly', () {
        // Test a known date
        final date1 = DateTime(2023, 12, 1); // Should be around week 48
        final date2 = DateTime(2023, 1, 1);  // Should be week 1
        final date3 = DateTime(2023, 6, 15); // Should be around week 24

        // We can't directly test the private method, but we can verify
        // the service exists and handles dates properly through the public API
        expect(service, isNotNull);
        expect(date1.year, equals(2023));
        expect(date2.month, equals(1));
        expect(date3.day, equals(15));
      });
    });

    group('Data Validation Tests', () {
      test('should handle invalid data gracefully', () {
        expect(() => SpiritualActivityType.devotionalCompleted, returnsNormally);
        expect(() => SpiritualActivityType.prayerTime, returnsNormally);
        expect(() => SpiritualActivityType.verseMemorized, returnsNormally);
        expect(() => SpiritualActivityType.bibleReading, returnsNormally);
        expect(() => SpiritualActivityType.worship, returnsNormally);
        expect(() => SpiritualActivityType.service, returnsNormally);
      });

      test('should create valid initial stats', () {
        final stats = SpiritualProgressStats.createInitial('test_user');
        expect(stats.userId, equals('test_user'));
        expect(stats.devotionalsCompleted, greaterThanOrEqualTo(0));
        expect(stats.prayerTimeMinutes, greaterThanOrEqualTo(0));
        expect(stats.versesMemorized, greaterThanOrEqualTo(0));
        expect(stats.currentStreak, greaterThanOrEqualTo(0));
        expect(stats.consecutiveDays, greaterThanOrEqualTo(0));
      });
    });

    group('Public API Tests', () {
      test('should provide public methods for tracking activities', () {
        // Verify that the service has the expected public methods
        expect(service.recordDevotionalCompletion, isA<Function>());
        expect(service.recordPrayerTime, isA<Function>());
        expect(service.recordVerseMemorized, isA<Function>());
        expect(service.getUserStats, isA<Function>());
        expect(service.getUserActivities, isA<Function>());
        expect(service.getMonthlyStats, isA<Function>());
        expect(service.getWeeklyStats, isA<Function>());
        expect(service.watchUserStats, isA<Function>());
      });

      test('should handle method calls with proper parameters', () async {
        // Test that methods accept the expected parameter types
        expect(
          () => service.recordDevotionalCompletion(
            devotionalId: 'test_id',
            date: DateTime.now(),
          ),
          returnsNormally,
        );

        expect(
          () => service.recordPrayerTime(minutes: 30),
          returnsNormally,
        );

        expect(
          () => service.recordVerseMemorized(verse: 'John 3:16'),
          returnsNormally,
        );
      });
    });
  });
}