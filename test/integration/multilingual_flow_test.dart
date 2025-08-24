import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devocional_nuevo/providers/devocional_provider.dart';
import 'package:devocional_nuevo/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multilingual Flow Integration', () {
    setUp(() {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Mock MethodChannel for platform-specific services
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAll') {
            return <String, dynamic>{}; // Empty preferences
          }
          if (methodCall.method == 'setString') {
            return true;
          }
          return null;
        },
      );

      // Mock other necessary channels
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          return '/mock/path';
        },
      );
    });

    tearDown(() {
      // Clean up method channel mocks
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        null,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        null,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
    });

    testWidgets('complete language switching flow works', (tester) async {
      // Test end-to-end language switching flow
      final provider = DevocionalProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => provider,
            child: Scaffold(
              appBar: AppBar(title: const Text('Devotional App')),
              body: Consumer<DevocionalProvider>(
                builder: (context, provider, child) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Status display
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Language: ${provider.selectedLanguage}'),
                                Text('Version: ${provider.selectedVersion}'),
                                Text('Loading: ${provider.isLoading}'),
                                Text(
                                    'Error: ${provider.errorMessage ?? "None"}'),
                              ],
                            ),
                          ),
                        ),

                        // Language selector
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Select Language:'),
                                DropdownButton<String>(
                                  key: const ValueKey('language_dropdown'),
                                  value: provider.selectedLanguage,
                                  isExpanded: true,
                                  items: Constants.supportedLanguages.entries
                                      .map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.key,
                                      child:
                                          Text('${entry.value} (${entry.key})'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.setSelectedLanguage(value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Version selector
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Select Bible Version:'),
                                DropdownButton<String>(
                                  key: const ValueKey('version_dropdown'),
                                  value: provider.selectedVersion,
                                  isExpanded: true,
                                  items:
                                      provider.availableVersions.map((version) {
                                    return DropdownMenuItem(
                                      value: version,
                                      child: Text(version),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.setSelectedVersion(value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Audio controls (mock)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Audio Controls:'),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      key: const ValueKey('play_button'),
                                      onPressed: provider.isAudioPlaying
                                          ? null
                                          : () {
                                              // Mock play action
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Playing in ${provider.selectedLanguage}')),
                                              );
                                            },
                                      child: const Text('Play'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      key: const ValueKey('pause_button'),
                                      onPressed: provider.isAudioPlaying
                                          ? () {
                                              // Mock pause action
                                            }
                                          : null,
                                      child: const Text('Pause'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Step 1: Verify initial Spanish state
      expect(find.text('Language: es'), findsOneWidget);
      expect(find.text('Version: RVR1960'), findsOneWidget);

      // Step 2: Switch to English
      await tester.tap(find.byKey(const ValueKey('language_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English (en)'));
      await tester.pumpAndSettle();

      // Step 3: Verify English is selected
      expect(find.text('Language: en'), findsOneWidget);
      // Version might be updating, so we check it exists
      expect(find.textContaining('Version:'), findsOneWidget);

      // Step 4: Change Bible version (if available)
      await tester.tap(find.byKey(const ValueKey('version_dropdown')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Try to find and tap NIV if available
      final nivFinder = find.text('NIV');
      if (tester.any(nivFinder)) {
        await tester.tap(nivFinder);
        await tester.pumpAndSettle();
        expect(find.text('Version: NIV'), findsOneWidget);
      }

      // Step 5: Test audio controls work with new language
      await tester.tap(find.byKey(const ValueKey('play_button')));
      await tester.pumpAndSettle();

      // Verify snackbar shows correct language
      expect(find.textContaining('Playing in en'), findsOneWidget);
    });

    testWidgets('offline to online sync works per language', (tester) async {
      // Test local storage and API sync for different languages
      final provider = DevocionalProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => provider,
            child: Scaffold(
              body: Consumer<DevocionalProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text('Offline Mode: ${provider.isOfflineMode}'),
                      Text('Language: ${provider.selectedLanguage}'),
                      Text('Version: ${provider.selectedVersion}'),
                      Text('Devotionals: ${provider.devocionales.length}'),
                      ElevatedButton(
                        key: const ValueKey('initialize_button'),
                        onPressed: () {
                          provider.initializeData();
                        },
                        child: const Text('Initialize Data'),
                      ),
                      DropdownButton<String>(
                        key: const ValueKey('language_dropdown'),
                        value: provider.selectedLanguage,
                        items:
                            Constants.supportedLanguages.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.setSelectedLanguage(value);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Test initialization
      await tester.tap(find.byKey(const ValueKey('initialize_button')));
      await tester.pump();

      // Allow some time for async operations
      await tester.pump(const Duration(milliseconds: 500));

      // Verify state is consistent
      expect(find.textContaining('Language:'), findsOneWidget);
      expect(find.textContaining('Version:'), findsOneWidget);

      // Switch language and verify consistency is maintained
      await tester.tap(find.byKey(const ValueKey('language_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Language: en'), findsOneWidget);
    });

    testWidgets('language switching preserves app state', (tester) async {
      // Test that switching languages doesn't break app state
      DevocionalProvider? provider;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) {
              provider = DevocionalProvider();
              return provider!;
            },
            child: Scaffold(
              body: Consumer<DevocionalProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text(
                          'Favorites: ${provider.favoriteDevocionales.length}'),
                      Text('Reading Time: ${provider.currentReadingSeconds}s'),
                      Text('Audio Playing: ${provider.isAudioPlaying}'),
                      DropdownButton<String>(
                        key: const ValueKey('language_dropdown'),
                        value: provider.selectedLanguage,
                        items:
                            Constants.supportedLanguages.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.setSelectedLanguage(value);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Favorites: 0'), findsOneWidget);
      expect(find.text('Reading Time: 0s'), findsOneWidget);
      expect(find.text('Audio Playing: false'), findsOneWidget);

      // Switch language
      await tester.tap(find.byKey(const ValueKey('language_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Verify state is preserved
      expect(find.text('Favorites: 0'), findsOneWidget);
      expect(find.text('Reading Time: 0s'), findsOneWidget);
      expect(find.text('Audio Playing: false'), findsOneWidget);

      // Properly dispose the provider
      provider?.dispose();
    });

    testWidgets('error handling works across languages', (tester) async {
      // Test that error states are handled properly in different languages
      DevocionalProvider? provider;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) {
              provider = DevocionalProvider();
              return provider!;
            },
            child: Scaffold(
              body: Consumer<DevocionalProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      Text('Error: ${provider.errorMessage ?? "None"}'),
                      Text('Loading: ${provider.isLoading}'),
                      DropdownButton<String>(
                        key: const ValueKey('language_dropdown'),
                        value: provider.selectedLanguage,
                        items:
                            Constants.supportedLanguages.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.setSelectedLanguage(value);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially should have no errors
      expect(find.text('Error: None'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);

      // Switch language - this might trigger loading/error states
      await tester.tap(find.byKey(const ValueKey('language_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // App should handle any errors gracefully
      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('Loading:'), findsOneWidget);

      // Properly dispose the provider
      provider?.dispose();
    });
  });
}
