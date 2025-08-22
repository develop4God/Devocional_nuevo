// test/devocional_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';

void main() {
  group('Devocional Model Tests', () {
    late Devocional testDevocional;
    late ParaMeditar testParaMeditar;

    setUp(() {
      testParaMeditar = ParaMeditar(
        cita: 'Juan 3:16',
        texto: 'De tal manera amó Dios al mundo...',
      );

      testDevocional = Devocional(
        id: 'test-devocional-1',
        versiculo:
            'Juan 3:16 - De tal manera amó Dios al mundo, que ha dado a su Hijo unigénito...',
        reflexion: 'Esta es una reflexión sobre el amor de Dios.',
        paraMeditar: [testParaMeditar],
        oracion: 'Padre celestial, gracias por tu amor incondicional.',
        date: DateTime(2025, 1, 1),
        version: 'RVR1960',
        language: 'es',
        tags: ['Amor', 'Salvación'],
      );
    });

    test('ParaMeditar should create correctly with required fields', () {
      expect(testParaMeditar.cita, 'Juan 3:16');
      expect(testParaMeditar.texto, 'De tal manera amó Dios al mundo...');
    });

    test('ParaMeditar should serialize to JSON correctly', () {
      final json = testParaMeditar.toJson();

      expect(json['cita'], 'Juan 3:16');
      expect(json['texto'], 'De tal manera amó Dios al mundo...');
    });

    test('ParaMeditar should deserialize from JSON correctly', () {
      final json = {
        'cita': 'Romanos 5:8',
        'texto': 'Mas Dios muestra su amor para con nosotros...'
      };

      final paraMeditar = ParaMeditar.fromJson(json);

      expect(paraMeditar.cita, 'Romanos 5:8');
      expect(
          paraMeditar.texto, 'Mas Dios muestra su amor para con nosotros...');
    });

    test('Devocional should create correctly with all fields', () {
      expect(testDevocional.id, 'test-devocional-1');
      expect(testDevocional.versiculo, contains('Juan 3:16'));
      expect(testDevocional.reflexion,
          'Esta es una reflexión sobre el amor de Dios.');
      expect(testDevocional.paraMeditar.length, 1);
      expect(testDevocional.oracion,
          'Padre celestial, gracias por tu amor incondicional.');
      expect(testDevocional.date, DateTime(2025, 1, 1));
      expect(testDevocional.version, 'RVR1960');
      expect(testDevocional.language, 'es');
      expect(testDevocional.tags, ['Amor', 'Salvación']);
    });

    test('Devocional should serialize to JSON correctly', () {
      final json = testDevocional.toJson();

      expect(json['id'], 'test-devocional-1');
      expect(json['versiculo'], contains('Juan 3:16'));
      expect(json['reflexion'], 'Esta es una reflexión sobre el amor de Dios.');
      expect(json['para_meditar'], isA<List>());
      expect(json['para_meditar'][0], isA<Map<String, dynamic>>());
      expect(json['oracion'],
          'Padre celestial, gracias por tu amor incondicional.');
      expect(json['date'], isA<String>()); // Should be ISO8601 string
      expect(json['version'], 'RVR1960');
      expect(json['language'], 'es');
      expect(json['tags'], ['Amor', 'Salvación']);
    });

    test('Devocional should deserialize from JSON correctly', () {
      final json = testDevocional.toJson();
      final recreatedDevocional = Devocional.fromJson(json);

      expect(recreatedDevocional.id, testDevocional.id);
      expect(recreatedDevocional.versiculo, testDevocional.versiculo);
      expect(recreatedDevocional.reflexion, testDevocional.reflexion);
      expect(recreatedDevocional.paraMeditar.length,
          testDevocional.paraMeditar.length);
      expect(recreatedDevocional.paraMeditar[0].cita,
          testDevocional.paraMeditar[0].cita);
      expect(recreatedDevocional.oracion, testDevocional.oracion);
      expect(recreatedDevocional.date, testDevocional.date);
      expect(recreatedDevocional.version, testDevocional.version);
      expect(recreatedDevocional.language, testDevocional.language);
      expect(recreatedDevocional.tags, testDevocional.tags);
    });

    test('Devocional should handle empty paraMeditar list', () {
      final devocionalWithoutParaMeditar = Devocional(
        id: 'test-2',
        versiculo: 'Test verse',
        reflexion: 'Test reflection',
        paraMeditar: [], // Empty list
        oracion: 'Test prayer',
        date: DateTime.now(),
        version: 'RVR1960',
        language: 'es',
        tags: [],
      );

      expect(devocionalWithoutParaMeditar.paraMeditar, isEmpty);

      final json = devocionalWithoutParaMeditar.toJson();
      final recreated = Devocional.fromJson(json);

      expect(recreated.paraMeditar, isEmpty);
    });

    test('Devocional should handle empty tags list', () {
      final devocionalWithoutTags = Devocional(
        id: 'test-3',
        versiculo: 'Test verse',
        reflexion: 'Test reflection',
        paraMeditar: [],
        oracion: 'Test prayer',
        date: DateTime.now(),
        version: 'RVR1960',
        language: 'es',
        tags: [], // Empty tags
      );

      expect(devocionalWithoutTags.tags, isEmpty);

      final json = devocionalWithoutTags.toJson();
      final recreated = Devocional.fromJson(json);

      expect(recreated.tags, isEmpty);
    });

    test('Devocional should handle very long content', () {
      final longContent = 'A' * 10000; // Very long string

      final devocionalWithLongContent = Devocional(
        id: 'test-long',
        versiculo: longContent,
        reflexion: longContent,
        paraMeditar: [ParaMeditar(cita: 'Test', texto: longContent)],
        oracion: longContent,
        date: DateTime.now(),
        version: 'RVR1960',
        language: 'es',
        tags: ['Long'],
      );

      expect(devocionalWithLongContent.versiculo.length, 10000);
      expect(devocionalWithLongContent.reflexion.length, 10000);
      expect(devocionalWithLongContent.paraMeditar[0].texto.length, 10000);
      expect(devocionalWithLongContent.oracion.length, 10000);
    });

    test('Devocional should handle special characters and unicode', () {
      final specialContent = 'Ñáñez αβγδε 中文 🙏 ❤️ 💙';

      final devocionalWithSpecialChars = Devocional(
        id: 'test-special',
        versiculo: specialContent,
        reflexion: specialContent,
        paraMeditar: [ParaMeditar(cita: specialContent, texto: specialContent)],
        oracion: specialContent,
        date: DateTime.now(),
        version: 'RVR1960',
        language: 'es',
        tags: [specialContent],
      );

      final json = devocionalWithSpecialChars.toJson();
      final recreated = Devocional.fromJson(json);

      expect(recreated.versiculo, specialContent);
      expect(recreated.reflexion, specialContent);
      expect(recreated.paraMeditar[0].cita, specialContent);
      expect(recreated.paraMeditar[0].texto, specialContent);
      expect(recreated.oracion, specialContent);
      expect(recreated.tags?.first, specialContent);
    });

    test('Devocional should handle different date formats correctly', () {
      final testDates = [
        DateTime(2025, 1, 1),
        DateTime(2024, 12, 31, 23, 59, 59),
        DateTime(1990, 6, 15, 12, 30, 45),
        DateTime.now(),
      ];

      for (final testDate in testDates) {
        final devocional = Devocional(
          id: 'date-test',
          versiculo: 'Test verse',
          reflexion: 'Test reflection',
          paraMeditar: [],
          oracion: 'Test prayer',
          date: testDate,
          version: 'RVR1960',
          language: 'es',
          tags: ['Test'],
        );
        final json = devocional.toJson();
        final recreated = Devocional.fromJson(json);

        // Compare dates by day since toJson only stores date part
        expect(recreated.date.year, testDate.year);
        expect(recreated.date.month, testDate.month);
        expect(recreated.date.day, testDate.day);
      }
    });

    test('Devocional should create new instances with different properties',
        () {
      final updatedDevocional = Devocional(
        id: 'new-id',
        versiculo: 'New verse',
        reflexion: testDevocional.reflexion,
        paraMeditar: testDevocional.paraMeditar,
        oracion: testDevocional.oracion,
        date: testDevocional.date,
        version: testDevocional.version,
        language: testDevocional.language,
        tags: ['New Tag'],
      );

      expect(updatedDevocional.id, 'new-id');
      expect(updatedDevocional.versiculo, 'New verse');
      expect(updatedDevocional.tags, ['New Tag']);

      // Other fields should match what we set
      expect(updatedDevocional.reflexion, testDevocional.reflexion);
      expect(updatedDevocional.oracion, testDevocional.oracion);
      expect(updatedDevocional.date, testDevocional.date);
    });

    test('Devocional equality should work correctly', () {
      final devocional1 = testDevocional;
      final devocional2 = Devocional.fromJson(testDevocional.toJson());

      // They should be equal in content
      expect(devocional1.id, devocional2.id);
      expect(devocional1.versiculo, devocional2.versiculo);
      expect(devocional1.date, devocional2.date);
    });

    test('ParaMeditar should handle empty strings', () {
      final emptyParaMeditar = ParaMeditar(
        cita: '',
        texto: '',
      );

      expect(emptyParaMeditar.cita, isEmpty);
      expect(emptyParaMeditar.texto, isEmpty);

      final json = emptyParaMeditar.toJson();
      final recreated = ParaMeditar.fromJson(json);

      expect(recreated.cita, isEmpty);
      expect(recreated.texto, isEmpty);
    });
  });
}
