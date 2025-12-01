import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/services/tts/i_tts_service.dart';
import 'package:devocional_nuevo/services/tts/voice_settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mockito/mockito.dart';

class MockFlutterTts extends Mock implements FlutterTts {}

class MockVoiceSettingsService extends Mock implements VoiceSettingsService {}

void main() {
  group('TtsService', () {
    late MockFlutterTts mockFlutterTts;
    late MockVoiceSettingsService mockVoiceSettingsService;
    late ITtsService ttsService;

    setUp(() {
      mockFlutterTts = MockFlutterTts();
      mockVoiceSettingsService = MockVoiceSettingsService();
      ttsService = TtsService.forTest(
        flutterTts: mockFlutterTts,
        voiceSettingsService: mockVoiceSettingsService,
      );
    });

    tearDown(() {
      // Ensure the service is disposed after each test
      ttsService.dispose();
    });

    test('initialize initializes TTS and sets initial state', () async {
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.initialize();
      expect(ttsService.currentState, TtsState.idle);
      verify(mockFlutterTts.setLanguage(any)).called(1);
    });

    test('speakDevotional speaks the devotional text', () async {
      final devotional = Devocional(
        id: '1',
        titulo: 'Test Title',
        reflexion: 'Test Reflection',
        fecha: DateTime.now(),
        versiculo: 'Test Verse',
      );

      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.speakDevotional(devotional);
      verify(mockFlutterTts.speak(devotional.reflexion)).called(1);
      expect(ttsService.currentState, TtsState.playing);
    });

    test('speakText speaks the given text', () async {
      const text = 'Test Text';
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.speakText(text);
      verify(mockFlutterTts.speak(text)).called(1);
      expect(ttsService.currentState, TtsState.playing);
    });

    test('pause pauses the TTS', () async {
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.pause()).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.initialize();
      await ttsService.speakText('test');
      await Future.delayed(const Duration(milliseconds: 100));
      await ttsService.pause();
      verify(mockFlutterTts.pause()).called(1);
      expect(ttsService.currentState, TtsState.paused);
    });

    test('resume resumes the TTS', () async {
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.initialize();
      await ttsService.speakText('test');
      await Future.delayed(const Duration(milliseconds: 100));
      await ttsService.pause();
      await ttsService.resume();
      verify(mockFlutterTts.speak(any)).called(2); // Called twice: initial speak and resume
      expect(ttsService.currentState, TtsState.playing);
    });

    test('stop stops the TTS', () async {
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.stop()).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.initialize();
      await ttsService.stop();
      verify(mockFlutterTts.stop()).called(1);
      expect(ttsService.currentState, TtsState.stopping);
    });

    test('setLanguage sets the language', () async {
      const language = 'en-US';
      when(mockFlutterTts.setLanguage(language)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.setLanguage(language);
      verify(mockFlutterTts.setLanguage(language)).called(1);
    });

    test('setSpeechRate sets the speech rate', () async {
      const rate = 0.7;
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(rate)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.setSpeechRate(rate);
      verify(mockFlutterTts.setSpeechRate(rate)).called(1);
    });

    test('dispose disposes the service', () async {
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.stop()).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.initialize();
      await ttsService.dispose();
      verify(mockFlutterTts.stop()).called(1);
      expect(ttsService.isDisposed, true);
    });

    test('formatBibleBook formats Bible book references', () {
      const reference = 'Génesis 1:1';
      final formattedReference = ttsService.formatBibleBook(reference);
      expect(formattedReference, 'Génesis 1:1');
    });

    test('initializeTtsOnAppStart initializes TTS with the given language', () async {
      const languageCode = 'es';
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.initializeTtsOnAppStart(languageCode);
      verify(mockFlutterTts.setLanguage(any)).called(1);
    });

    test('assignDefaultVoiceForLanguage assigns the default voice for the language', () async {
      const languageCode = 'es';
      when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setVolume(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.setPitch(any)).thenAnswer((_) async => 1);
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) async => 1);
      when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

      await ttsService.assignDefaultVoiceForLanguage(languageCode);
      verify(mockFlutterTts.setLanguage(any)).called(1);
    });
  });
}