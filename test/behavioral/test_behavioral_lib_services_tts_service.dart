import 'package:devocional_nuevo/models/devocional_model.dart';
import 'package:devocional_nuevo/services/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mockito/mockito.dart';

class MockFlutterTts extends Mock implements FlutterTts {}
class MockVoiceSettingsService extends Mock implements VoiceSettingsService {}

void main() {
  group('TtsService', () {
    late TtsService ttsService;
    late MockFlutterTts mockFlutterTts;
    late MockVoiceSettingsService mockVoiceSettingsService;

    setUp(() {
      mockFlutterTts = MockFlutterTts();
      mockVoiceSettingsService = MockVoiceSettingsService();
      ttsService = TtsService.forTest(
        flutterTts: mockFlutterTts,
        voiceSettingsService: mockVoiceSettingsService,
      );
    });

    tearDown(() {
      ttsService.dispose();
    });

    test('User speaks a devotional, TTS starts playing', () async {
      // Given: A devotional and the service is initialized
      final devotional = Devocional(id: '1', reflexion: 'Test reflection');
      when(mockFlutterTts.speak(any)).thenAnswer((_) => Future.value(1));
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) => Future.value(true));

      // When: The user calls speakDevotional
      await ttsService.speakDevotional(devocional);

      // Then: The TTS should be playing
      expect(ttsService.isPlaying, true);
      verify(mockFlutterTts.speak('Test reflection')).called(1);
    });

    test('User pauses and resumes the TTS, playback continues', () async {
      // Given: TTS is playing
      final devotional = Devocional(id: '1', reflexion: 'Test reflection');
      when(mockFlutterTts.speak(any)).thenAnswer((_) => Future.value(1));
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) => Future.value(true));
      await ttsService.speakDevotional(devocional);
      await Future.delayed(const Duration(milliseconds: 100)); // Allow time for state change

      // When: User pauses and resumes
      await ttsService.pause();
      expect(ttsService.isPaused, true);
      await ttsService.resume();

      // Then: TTS should be playing again
      expect(ttsService.isPlaying, true);
      verify(mockFlutterTts.speak('Test reflection')).called(2); // Called twice, once for initial speak, once for resume
    });

    test('User stops the TTS, playback stops immediately', () async {
      // Given: TTS is playing
      final devotional = Devocional(id: '1', reflexion: 'Test reflection');
      when(mockFlutterTts.speak(any)).thenAnswer((_) => Future.value(1));
      when(mockFlutterTts.stop()).thenAnswer((_) => Future.value(1));
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) => Future.value(true));
      await ttsService.speakDevotional(devocional);
      await Future.delayed(const Duration(milliseconds: 100)); // Allow time for state change

      // When: User stops the TTS
      await ttsService.stop();

      // Then: TTS should be stopped
      expect(ttsService.currentState, TtsState.idle);
      verify(mockFlutterTts.stop()).called(1);
    });

    test('TTS service handles an error during speakText', () async {
      // Given: The TTS service is initialized and an error will occur
      when(mockFlutterTts.speak(any)).thenThrow(Exception('Simulated error'));
      when(mockFlutterTts.awaitSpeakCompletion(any)).thenAnswer((_) => Future.value(true));

      // When: speakText is called
      try {
        await ttsService.speakText('Test text');
      } catch (e) {
        // Then: The state should be error
        expect(ttsService.currentState, TtsState.error);
        verify(mockFlutterTts.speak('Test text')).called(1);
        return; // Exit the test after verifying the error
      }
      fail('Expected an exception, but none was thrown.');
    });
  });
}