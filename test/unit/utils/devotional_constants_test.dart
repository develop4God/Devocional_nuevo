// test/unit/utils/devotional_constants_test.dart

import 'package:devocional_nuevo/utils/devotional_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DevotionalConstants - URL Generation', () {
    test('getDevocionalesApiUrl returns correct URL', () {
      final url = DevotionalConstants.getDevocionalesApiUrl(2024);
      expect(url, contains('Devocional_year_2024.json'));
      expect(url, startsWith('https://raw.githubusercontent.com'));
    });

    test('getDevocionalesApiUrlMultilingual returns backward compatible URL for Spanish RVR1960',
        () {
      final url = DevotionalConstants.getDevocionalesApiUrlMultilingual(
        2024,
        'es',
        'RVR1960',
      );
      expect(url, DevotionalConstants.getDevocionalesApiUrl(2024));
    });

    test('getDevocionalesApiUrlMultilingual returns new format for other languages',
        () {
      final url = DevotionalConstants.getDevocionalesApiUrlMultilingual(
        2024,
        'en',
        'KJV',
      );
      expect(url, contains('Devocional_year_2024_en_KJV.json'));
      expect(url, isNot(equals(DevotionalConstants.getDevocionalesApiUrl(2024))));
    });

    test('getDevocionalesApiUrlMultilingual handles Portuguese', () {
      final url = DevotionalConstants.getDevocionalesApiUrlMultilingual(
        2024,
        'pt',
        'ARC',
      );
      expect(url, contains('Devocional_year_2024_pt_ARC.json'));
    });

    test('getDevocionalesApiUrlMultilingual handles French', () {
      final url = DevotionalConstants.getDevocionalesApiUrlMultilingual(
        2024,
        'fr',
        'LSG1910',
      );
      expect(url, contains('Devocional_year_2024_fr_LSG1910.json'));
    });

    test('URL format is consistent across years', () {
      final url2023 = DevotionalConstants.getDevocionalesApiUrl(2023);
      final url2024 = DevotionalConstants.getDevocionalesApiUrl(2024);
      final url2025 = DevotionalConstants.getDevocionalesApiUrl(2025);

      expect(url2023, contains('2023'));
      expect(url2024, contains('2024'));
      expect(url2025, contains('2025'));

      expect(url2023.split('2023')[0], url2024.split('2024')[0]);
      expect(url2024.split('2024')[0], url2025.split('2025')[0]);
    });
  });

  group('DevotionalConstants - Language Maps', () {
    test('supportedLanguages contains all expected languages', () {
      expect(DevotionalConstants.supportedLanguages, {
        'es': 'Español',
        'en': 'English',
        'pt': 'Português',
        'fr': 'Français',
        'zh': 'Chinese (Coming Soon)',
      });
    });

    test('supportedLanguages keys are language codes', () {
      final keys = DevotionalConstants.supportedLanguages.keys;
      for (final key in keys) {
        expect(key.length, 2); // All language codes should be 2 characters
      }
    });

    test('bibleVersionsByLanguage contains all supported languages', () {
      final languageCodes = DevotionalConstants.supportedLanguages.keys;
      final versionKeys = DevotionalConstants.bibleVersionsByLanguage.keys;
      
      for (final code in languageCodes) {
        expect(versionKeys, contains(code));
      }
    });

    test('Spanish has correct Bible versions', () {
      final versions = DevotionalConstants.bibleVersionsByLanguage['es'];
      expect(versions, ['RVR1960', 'NVI']);
    });

    test('English has correct Bible versions', () {
      final versions = DevotionalConstants.bibleVersionsByLanguage['en'];
      expect(versions, ['KJV', 'NIV']);
    });

    test('Portuguese has correct Bible versions', () {
      final versions = DevotionalConstants.bibleVersionsByLanguage['pt'];
      expect(versions, ['ARC', 'NVI']);
    });

    test('French has correct Bible versions', () {
      final versions = DevotionalConstants.bibleVersionsByLanguage['fr'];
      expect(versions, ['LSG1910', 'TOB']);
    });

    test('Chinese has placeholder for coming soon', () {
      final versions = DevotionalConstants.bibleVersionsByLanguage['zh'];
      expect(versions, isEmpty);
    });
  });

  group('DevotionalConstants - Default Versions', () {
    test('defaultVersionByLanguage contains all supported languages', () {
      final languageCodes = DevotionalConstants.supportedLanguages.keys;
      final defaultKeys = DevotionalConstants.defaultVersionByLanguage.keys;
      
      for (final code in languageCodes) {
        expect(defaultKeys, contains(code));
      }
    });

    test('Spanish default version is RVR1960', () {
      expect(DevotionalConstants.defaultVersionByLanguage['es'], 'RVR1960');
    });

    test('English default version is KJV', () {
      expect(DevotionalConstants.defaultVersionByLanguage['en'], 'KJV');
    });

    test('Portuguese default version is ARC', () {
      expect(DevotionalConstants.defaultVersionByLanguage['pt'], 'ARC');
    });

    test('French default version is LSG1910', () {
      expect(DevotionalConstants.defaultVersionByLanguage['fr'], 'LSG1910');
    });

    test('Chinese has fallback to RVR1960', () {
      expect(DevotionalConstants.defaultVersionByLanguage['zh'], 'RVR1960');
    });

    test('default versions exist in their language version lists', () {
      DevotionalConstants.defaultVersionByLanguage.forEach((lang, defaultVer) {
        final versions = DevotionalConstants.bibleVersionsByLanguage[lang];
        if (versions != null && versions.isNotEmpty) {
          expect(versions, contains(defaultVer),
              reason: 'Default version $defaultVer for $lang should be in version list');
        }
      });
    });
  });

  group('DevotionalConstants - Preferences Keys', () {
    test('prefFavorites has unique key', () {
      expect(DevotionalConstants.prefFavorites, 'discovery_favorites');
    });

    test('prefSelectedLanguage has unique key', () {
      expect(DevotionalConstants.prefSelectedLanguage, 'discovery_selectedLanguage');
    });

    test('prefSelectedVersion has unique key', () {
      expect(DevotionalConstants.prefSelectedVersion, 'discovery_selectedVersion');
    });

    test('prefExperienceMode has unique key', () {
      expect(DevotionalConstants.prefExperienceMode, 'discovery_experienceMode');
    });

    test('all preference keys are unique', () {
      final keys = [
        DevotionalConstants.prefFavorites,
        DevotionalConstants.prefSelectedLanguage,
        DevotionalConstants.prefSelectedVersion,
        DevotionalConstants.prefExperienceMode,
      ];

      final uniqueKeys = keys.toSet();
      expect(uniqueKeys.length, keys.length,
          reason: 'All preference keys should be unique');
    });

    test('preference keys use discovery_ prefix', () {
      final keys = [
        DevotionalConstants.prefFavorites,
        DevotionalConstants.prefSelectedLanguage,
        DevotionalConstants.prefSelectedVersion,
        DevotionalConstants.prefExperienceMode,
      ];

      for (final key in keys) {
        expect(key, startsWith('discovery_'),
            reason: 'All keys should have discovery_ prefix to avoid conflicts');
      }
    });
  });

  group('DevotionalConstants - Data Integrity', () {
    test('no null values in supported languages', () {
      DevotionalConstants.supportedLanguages.forEach((code, name) {
        expect(code, isNotNull);
        expect(name, isNotNull);
        expect(code, isNotEmpty);
        expect(name, isNotEmpty);
      });
    });

    test('no null values in bible versions', () {
      DevotionalConstants.bibleVersionsByLanguage.forEach((lang, versions) {
        expect(lang, isNotNull);
        expect(versions, isNotNull);
        for (final version in versions) {
          expect(version, isNotNull);
          expect(version, isNotEmpty);
        }
      });
    });

    test('no null values in default versions', () {
      DevotionalConstants.defaultVersionByLanguage.forEach((lang, version) {
        expect(lang, isNotNull);
        expect(version, isNotNull);
        expect(lang, isNotEmpty);
        expect(version, isNotEmpty);
      });
    });
  });

  group('DevotionalConstants - Constants are immutable', () {
    test('supportedLanguages is const', () {
      expect(DevotionalConstants.supportedLanguages, isA<Map<String, String>>());
    });

    test('bibleVersionsByLanguage is const', () {
      expect(DevotionalConstants.bibleVersionsByLanguage, isA<Map<String, List<String>>>());
    });

    test('defaultVersionByLanguage is const', () {
      expect(DevotionalConstants.defaultVersionByLanguage, isA<Map<String, String>>());
    });

    test('preference keys are const strings', () {
      expect(DevotionalConstants.prefFavorites, isA<String>());
      expect(DevotionalConstants.prefSelectedLanguage, isA<String>());
      expect(DevotionalConstants.prefSelectedVersion, isA<String>());
      expect(DevotionalConstants.prefExperienceMode, isA<String>());
    });
  });
}
