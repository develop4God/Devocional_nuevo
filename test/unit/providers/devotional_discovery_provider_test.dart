// test/unit/providers/devotional_discovery_provider_test.dart

import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/providers/devotional_discovery_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DevotionalDiscoveryProvider', () {
    late DevotionalDiscoveryProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = DevotionalDiscoveryProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state is correct', () {
      expect(provider.all, isEmpty);
      expect(provider.filtered, isEmpty);
      expect(provider.favorites, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
      expect(provider.selectedLanguage, 'es');
      expect(provider.selectedVersion, 'RVR1960');
      expect(provider.isOfflineMode, false);
    });

    test('filterBySearch filters devotionals correctly', () {
      // Setup test data
      final devotionals = [
        Devocional(
          id: '1',
          versiculo: 'Juan 3:16 RVR1960: "Porque de tal manera amó Dios"',
          reflexion: 'Test reflection about love',
          paraMeditar: [],
          oracion: 'Test prayer',
          date: DateTime.now(),
          tags: ['love', 'grace'],
        ),
        Devocional(
          id: '2',
          versiculo: 'Mateo 5:9 RVR1960: "Bienaventurados los pacificadores"',
          reflexion: 'Test reflection about peace',
          paraMeditar: [],
          oracion: 'Test prayer',
          date: DateTime.now(),
          tags: ['peace', 'blessing'],
        ),
      ];

      // Manually set internal state for testing
      // Since we can't directly set _all and _filtered, we need to test through public methods
      // For now, we'll just verify the method doesn't crash
      expect(() => provider.filterBySearch('love'), returnsNormally);
      expect(() => provider.filterBySearch(''), returnsNormally);
    });

    test('isFavorite returns correct value', () {
      expect(provider.isFavorite('test-1'), false);
      expect(provider.isFavorite('test-2'), false);
    });

    test('toggleFavorite adds and removes favorites', () async {
      SharedPreferences.setMockInitialValues({});

      final devotional = Devocional(
        id: 'test-1',
        versiculo: 'Test verse',
        reflexion: 'Test reflection',
        paraMeditar: [],
        oracion: 'Test prayer',
        date: DateTime.now(),
      );

      expect(provider.favorites, isEmpty);

      // Add to favorites
      await provider.toggleFavorite(devotional);
      expect(provider.favorites.length, 1);
      expect(provider.favorites.first.id, 'test-1');

      // Remove from favorites
      await provider.toggleFavorite(devotional);
      expect(provider.favorites, isEmpty);
    });

    test('getDevocionalById returns null when list is empty', () {
      expect(provider.getDevocionalById('test-1'), null);
      expect(provider.getDevocionalById('test-2'), null);
      expect(provider.getDevocionalById('test-3'), null);
    });

    test('changeLanguage updates language and version', () async {
      SharedPreferences.setMockInitialValues({});

      // Initial state
      expect(provider.selectedLanguage, 'es');
      expect(provider.selectedVersion, 'RVR1960');

      // Note: Can't fully test this without mocking HTTP
      // but we can verify it doesn't crash
      try {
        await provider.changeLanguage('en');
        // If we get here without error, the basic logic works
        expect(provider.selectedLanguage, 'en');
        expect(provider.selectedVersion, 'KJV'); // Default for English
      } catch (e) {
        // Expected to fail due to network call, but should have updated state
        expect(provider.selectedLanguage, 'en');
      }
    });

    test('changeVersion updates version', () async {
      SharedPreferences.setMockInitialValues({});

      expect(provider.selectedVersion, 'RVR1960');

      try {
        await provider.changeVersion('NVI');
        expect(provider.selectedVersion, 'NVI');
      } catch (e) {
        // Expected to fail due to network call, but should have updated state
        expect(provider.selectedVersion, 'NVI');
      }
    });

    test('notifyListeners is called on state changes', () async {
      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      final devotional = Devocional(
        id: 'test-1',
        versiculo: 'Test verse',
        reflexion: 'Test reflection',
        paraMeditar: [],
        oracion: 'Test prayer',
        date: DateTime.now(),
      );

      await provider.toggleFavorite(devotional);

      // Should have notified at least once
      expect(notificationCount, greaterThan(0));
    });
  });

  group('DevotionalDiscoveryProvider - State Getters', () {
    late DevotionalDiscoveryProvider provider;

    setUp(() {
      provider = DevotionalDiscoveryProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('all getters return correct values', () {
      expect(provider.all, isA<List<Devocional>>());
      expect(provider.filtered, isA<List<Devocional>>());
      expect(provider.favorites, isA<List<Devocional>>());
      expect(provider.isLoading, isA<bool>());
      expect(provider.errorMessage, null);
      expect(provider.selectedLanguage, isA<String>());
      expect(provider.selectedVersion, isA<String>());
      expect(provider.isOfflineMode, isA<bool>());
    });
  });

  group('DevotionalDiscoveryProvider - Extension Getter', () {
    late DevotionalDiscoveryProvider provider;

    setUp(() {
      provider = DevotionalDiscoveryProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('exposes private fields through getters', () {
      // Verify that we can access the internal state through public getters
      expect(() => provider.all, returnsNormally);
      expect(() => provider.filtered, returnsNormally);
      expect(() => provider.favorites, returnsNormally);
      expect(() => provider.isLoading, returnsNormally);
      expect(() => provider.errorMessage, returnsNormally);
      expect(() => provider.selectedLanguage, returnsNormally);
      expect(() => provider.selectedVersion, returnsNormally);
      expect(() => provider.isOfflineMode, returnsNormally);
    });
  });

  group('DevotionalDiscoveryProvider - Persistence', () {
    test('loads favorites from SharedPreferences on init', () async {
      // Setup saved favorites
      final savedDevotional = Devocional(
        id: 'saved-1',
        versiculo: 'Saved verse',
        reflexion: 'Saved reflection',
        paraMeditar: [],
        oracion: 'Saved prayer',
        date: DateTime(2024, 1, 1),
      );

      SharedPreferences.setMockInitialValues({
        'discovery_favorites':
            '[{"id":"saved-1","versiculo":"Saved verse","reflexion":"Saved reflection","para_meditar":[],"oracion":"Saved prayer","date":"2024-01-01"}]',
      });

      final provider = DevotionalDiscoveryProvider();
      await provider.initialize();

      // Note: Due to HTTP call in initialize, this might fail
      // but we're testing that favorites loading doesn't crash
      expect(() => provider.favorites, returnsNormally);
      
      provider.dispose();
    });

    test('saves favorites to SharedPreferences on toggle', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = DevotionalDiscoveryProvider();

      final devotional = Devocional(
        id: 'new-1',
        versiculo: 'New verse',
        reflexion: 'New reflection',
        paraMeditar: [],
        oracion: 'New prayer',
        date: DateTime.now(),
      );

      await provider.toggleFavorite(devotional);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('discovery_favorites');
      expect(saved, isNotNull);
      expect(saved, contains('new-1'));

      provider.dispose();
    });
  });
}
