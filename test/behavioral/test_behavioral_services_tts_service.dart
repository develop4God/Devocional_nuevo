import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:devocional_nuevo/services/tts_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:devocional_nuevo/services/tts/voice_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/models/devocional_model.dart';

@GenerateMocks([VoiceSettingsService, FlutterTts, SharedPreferences])
void main() {
  late TtsService instance;
  late MockVoiceSettingsService mockVoiceSettingsService;
  late MockFlutterTts mockFlutterTts;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    mockVoiceSettingsService = MockVoiceSettingsService();
    mockFlutterTts = MockFlutterTts();
    mockSharedPreferences = MockSharedPreferences();
    
    // Mock platform channels if needed
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        MethodChannel('flutter_tts'),
        (call) async {
          switch (call.method) {
            case 'getLanguages':
              return ['es-ES', 'en-US'];
            default:
              return null;
          }
        }
      );

    when(mockVoiceSettingsService.getAvailableVoices()).thenAnswer((_) async => []);
    when(mockVoiceSettingsService.getVoicesForLanguage(any)).thenAnswer((_) async => []);
    when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);
    when(mockSharedPreferences.getDouble(any)).thenReturn(0.5);
    when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);
    when(mockSharedPreferences.getString(any)).thenReturn(null);
    when(mockSharedPreferences.setStringList(any, any)).thenAnswer((_) async => true);
    when(mockSharedPreferences.getStringList(any)).thenReturn(null);
    when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);
    when(mockSharedPreferences.clear()).thenAnswer((_) async => true);

    SharedPreferences.setMockInitialValues({});

    instance = TtsService.forTest(
      flutterTts: mockFlutterTts,
      voiceSettingsService: mockVoiceSettingsService,
    );
  });

  tearDown(() {
    instance.dispose();
    // Clean up platform channel mocks
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        MethodChannel('flutter_tts'),
        null,
      );
  });

  test('User initiates speech/audio playback of a devotional', () async {
    // Given: User is ready to speak a devotional
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);

    // When: User performs speak action
    await instance.speakDevotional(devotional);
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: System responds correctly
    verify(mockFlutterTts.speak('Test text')).called(1);
    expect(instance.isPlaying, true);
    expect(instance.currentState, TtsState.playing);
    expect(instance.currentDevocionalId, '1');
  });

  test('User pauses playback', () async {
    // Given: User is ready to pause
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    await instance.speakDevotional(devotional);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(instance.isPlaying, true);

    // When: User performs pause action
    await instance.pause();
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: System responds correctly
    verify(mockFlutterTts.pause()).called(1);
    expect(instance.isPaused, true);
    expect(instance.currentState, TtsState.paused);
  });

  test('User stops operation', () async {
    // Given: User is ready to stop
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    await instance.speakDevotional(devotional);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(instance.isPlaying, true);

    // When: User performs stop action
    await instance.stop();
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: System responds correctly
    verify(mockFlutterTts.stop()).called(1);
    expect(instance.currentState, TtsState.idle);
  });

  test('User resumes paused operation', () async {
    // Given: User is ready to resume
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    await instance.speakDevotional(devotional);
    await Future.delayed(const Duration(milliseconds: 100));
    await instance.pause();
    await Future.delayed(const Duration(milliseconds: 100));
    expect(instance.isPaused, true);

    // When: User performs resume action
    await instance.resume();
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: System responds correctly
    verify(mockFlutterTts.speak('Test text')).called(2); // Called twice, once for initial speak, once for resume
    expect(instance.isPlaying, true);
    expect(instance.currentState, TtsState.playing);
  });

  test('User changes language', () async {
    // Given: User wants to change the language
    when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
    when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

    // When: User sets a new language
    await instance.setLanguage('en-US');
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: System responds correctly
    verify(mockFlutterTts.setLanguage('en-US')).called(1);
  });

  test('User sees meaningful error when speakDevotional fails', () async {
    // Given: TTS fails to speak
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    when(mockFlutterTts.speak(any)).thenThrow(TtsException('Simulated error'));

    // When: User attempts to speak
    try {
      await instance.speakDevotional(devocional);
    } catch (e) {
      // Then: User sees helpful error message
      expect(e, isA<TtsException>());
      expect((e as TtsException).message, 'Simulated error');
    }
  });

  test('User can recover from error state', () async {
    // Given: User encountered an error
    when(mockFlutterTts.speak(any)).thenThrow(TtsException('Simulated error'));
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    try {
      await instance.speakDevotional(devotional);
    } catch (e) {}
    expect(instance.currentState, TtsState.error);

    // When: User retries after fixing issue
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
    await instance.speakDevotional(devotional);
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: Error is cleared and operation succeeds
    expect(instance.currentState, TtsState.playing);
  });

  test('Rapid user clicks are handled gracefully', () async {
    // Given: User rapidly clicks button
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    final futures = List.generate(5, (_) => instance.speakDevotional(devotional));

    // When: All requests complete
    await Future.wait(futures);
    await Future.delayed(const Duration(milliseconds: 200));

    // Then: Only one operation succeeded, others ignored
    verify(mockFlutterTts.speak(any)).called(5);
  });

  test('Complete user journey through states', () async {
    // Initial state
    expect(instance.currentState, TtsState.idle);

    // Start operation
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    final future = instance.speakDevotional(devotional);
    await Future.delayed(const Duration(milliseconds: 50));
    expect(instance.currentState, TtsState.playing);

    // Complete operation
    await future;
    await Future.delayed(const Duration(milliseconds: 100));
    expect(instance.currentState, TtsState.idle);

    // Pause operation
    await instance.pause();
    await Future.delayed(const Duration(milliseconds: 100));
    expect(instance.currentState, TtsState.paused);

    // Resume operation
    await instance.resume();
    await Future.delayed(const Duration(milliseconds: 100));
    expect(instance.currentState, TtsState.playing);

    // Stop operation
    await instance.stop();
    await Future.delayed(const Duration(milliseconds: 100));
    expect(instance.currentState, TtsState.idle);
  });

  test('User disposes the service', () async {
    // Given: The service is initialized
    when(mockFlutterTts.speak(any)).thenAnswer((_) async => 1);
    final devotional = Devocional(id: '1', reflexion: 'Test text');
    await instance.speakDevotional(devotional);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(instance.isPlaying, true);

    // When: User disposes the service
    await instance.dispose();
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: Service is disposed and resources are released
    expect(instance.isDisposed, true);
    expect(instance.currentState, TtsState.idle);
  });

  test('User sets speech rate', () async {
    // Given: User wants to change the speech rate
    when(mockFlutterTts.setSpeechRate(any)).thenAnswer((_) async => 1);

    // When: User sets a new speech rate
    await instance.setSpeechRate(0.7);
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: System responds correctly
    verify(mockFlutterTts.setSpeechRate(0.7)).called(1);
  });

  test('User initializes TTS on app start', () async {
    // Given: App is starting
    when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
    when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

    // When: initializeTtsOnAppStart is called
    await instance.initializeTtsOnAppStart('es');
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: TTS is initialized with the correct language
    verify(mockFlutterTts.setLanguage('es-US')).called(1);
  });

  test('User assigns default voice for language', () async {
    // Given: User wants to assign a default voice
    when(mockFlutterTts.setLanguage(any)).thenAnswer((_) async => 1);
    when(mockVoiceSettingsService.loadSavedVoice(any)).thenAnswer((_) async => null);

    // When: assignDefaultVoiceForLanguage is called
    await instance.assignDefaultVoiceForLanguage('en');
    await Future.delayed(const Duration(milliseconds: 100));

    // Then: Default voice is assigned for the language
    verify(mockFlutterTts.setLanguage('en-US')).called(1);
  });
}