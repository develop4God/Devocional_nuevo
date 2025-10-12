// test/unit/blocs/bible_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:devocional_nuevo/blocs/bible/bible_bloc.dart';
import 'package:devocional_nuevo/blocs/bible/bible_event.dart';
import 'package:devocional_nuevo/blocs/bible/bible_state.dart';
import 'package:devocional_nuevo/models/bible_version.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BibleBloc Unit Tests', () {
    late BibleBloc bibleBloc;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
      bibleBloc = BibleBloc();
    });

    tearDown(() {
      bibleBloc.close();
    });

    test('should have correct initial state', () {
      expect(bibleBloc.state, isA<BibleInitial>());
    });

    group('SelectVerse', () {
      blocTest<BibleBloc, BibleState>(
        'should update selected verse when in BibleLoaded state',
        build: () => bibleBloc,
        seed: () => BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedVerse: 1,
        ),
        act: (bloc) => bloc.add(SelectVerse(10)),
        verify: (bloc) {
          final state = bloc.state as BibleLoaded;
          expect(state.selectedVerse, 10);
        },
      );
    });

    group('ToggleVerseSelection', () {
      blocTest<BibleBloc, BibleState>(
        'should add verse to selection when not selected',
        build: () => bibleBloc,
        seed: () => BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedVerses: {},
        ),
        act: (bloc) => bloc.add(ToggleVerseSelection('Juan|3|16')),
        verify: (bloc) {
          final state = bloc.state as BibleLoaded;
          expect(state.selectedVerses.contains('Juan|3|16'), true);
        },
      );

      blocTest<BibleBloc, BibleState>(
        'should remove verse from selection when already selected',
        build: () => bibleBloc,
        seed: () => BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedVerses: {'Juan|3|16'},
        ),
        act: (bloc) => bloc.add(ToggleVerseSelection('Juan|3|16')),
        verify: (bloc) {
          final state = bloc.state as BibleLoaded;
          expect(state.selectedVerses.contains('Juan|3|16'), false);
        },
      );
    });

    group('ClearVerseSelections', () {
      blocTest<BibleBloc, BibleState>(
        'should clear all verse selections',
        build: () => bibleBloc,
        seed: () => BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedVerses: {'Juan|3|16', 'Juan|3|17', 'Juan|3|18'},
        ),
        act: (bloc) => bloc.add(ClearVerseSelections()),
        verify: (bloc) {
          final state = bloc.state as BibleLoaded;
          expect(state.selectedVerses.isEmpty, true);
        },
      );
    });

    group('UpdateFontSize', () {
      blocTest<BibleBloc, BibleState>(
        'should update font size',
        build: () => bibleBloc,
        seed: () => BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          fontSize: 18.0,
        ),
        act: (bloc) => bloc.add(UpdateFontSize(24.0)),
        verify: (bloc) {
          final state = bloc.state as BibleLoaded;
          expect(state.fontSize, 24.0);
        },
      );
    });

    group('State Helpers', () {
      test('isVerseSelected should return correct value', () {
        final state = BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedVerses: {'Juan|3|16', 'Juan|3|17'},
        );

        expect(state.isVerseSelected('Juan|3|16'), true);
        expect(state.isVerseSelected('Juan|3|18'), false);
      });

      test('isVersePersistentlyMarked should return correct value', () {
        final state = BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          persistentlyMarkedVerses: {'Salmos|23|1', 'Salmos|23|2'},
        );

        expect(state.isVersePersistentlyMarked('Salmos|23|1'), true);
        expect(state.isVersePersistentlyMarked('Salmos|23|3'), false);
      });

      test('getSelectedVersesReference should format single verse correctly',
          () {
        final state = BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedVerses: {'Juan|3|16'},
        );

        expect(state.getSelectedVersesReference(), 'Juan 3:16');
      });

      test('getSelectedVersesReference should format verse range correctly',
          () {
        final state = BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedVerses: {'Juan|3|16', 'Juan|3|17', 'Juan|3|18'},
        );

        expect(state.getSelectedVersesReference(), 'Juan 3:16-18');
      });

      test(
          'getSelectedVersesReference should return empty string for no selection',
          () {
        final state = BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedVerses: {},
        );

        expect(state.getSelectedVersesReference(), '');
      });
    });

    group('copyWith', () {
      test('should create new state with updated values', () {
        final originalState = BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          fontSize: 18.0,
          selectedVerse: 1,
        );

        final newState =
            originalState.copyWith(fontSize: 24.0, selectedVerse: 10);

        expect(newState.fontSize, 24.0);
        expect(newState.selectedVerse, 10);
        // Original values should remain unchanged
        expect(originalState.fontSize, 18.0);
        expect(originalState.selectedVerse, 1);
      });

      test('should handle null clears correctly', () {
        final originalState = BibleLoaded(
          selectedVersion: BibleVersion(
            name: 'RVR1960',
            language: 'Spanish',
            languageCode: 'es',
            assetPath: 'assets/bible/rvr1960.db',
            dbFileName: 'rvr1960.db',
          ),
          availableVersions: [],
          books: [],
          selectedBookName: 'Genesis',
          selectedBookNumber: 1,
          selectedChapter: 5,
          selectedVerse: 10,
        );

        final newState = originalState.copyWith(
          clearBookSelection: true,
          clearChapterSelection: true,
          clearVerseSelection: true,
        );

        expect(newState.selectedBookName, null);
        expect(newState.selectedBookNumber, null);
        expect(newState.selectedChapter, null);
        expect(newState.selectedVerse, null);
      });
    });
  });
}
