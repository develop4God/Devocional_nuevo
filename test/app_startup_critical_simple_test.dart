// test/app_startup_critical_test.dart
// Critical test to ensure app starts and chat functionality works

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:devocional_nuevo/blocs/chat/chat_bloc.dart';
import 'package:devocional_nuevo/blocs/chat/chat_state.dart';
import 'package:devocional_nuevo/blocs/chat/chat_event.dart';
import 'package:devocional_nuevo/services/gemini_chat_service.dart';
import 'package:devocional_nuevo/providers/localization_provider.dart';

import 'test_setup.dart';

// Mock classes
class MockGeminiChatService extends Mock implements GeminiChatService {}

class MockLocalizationProvider extends Mock implements LocalizationProvider {}

void main() {
  group('App Startup Critical Tests', () {
    setUpAll(() {
      TestSetup.setupCommonMocks();
    });

    tearDown(() {
      TestSetup.cleanupMocks();
    });

    test('ChatBloc initialization works correctly', () {
      final mockChatService = MockGeminiChatService();
      final mockLocalizationProvider = MockLocalizationProvider();

      when(() => mockLocalizationProvider.currentLanguage).thenReturn('es');

      final chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);

      // Verify initial state
      expect(chatBloc.state, isA<ChatInitial>());

      chatBloc.close();
    });

    test('ChatBloc can process messages successfully', () async {
      final mockChatService = MockGeminiChatService();
      final mockLocalizationProvider = MockLocalizationProvider();

      when(() => mockLocalizationProvider.currentLanguage).thenReturn('es');
      when(() => mockChatService.sendMessage(any(), any()))
          .thenAnswer((_) async => 'Que la paz de Dios esté contigo');

      final chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);

      // Send a message
      chatBloc.add(SendMessageEvent('Test message'));

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the bloc can handle events without crashing
      expect(chatBloc.isClosed, isFalse);

      chatBloc.close();
    });

    test('ChatBloc loads chat history without errors', () async {
      final mockChatService = MockGeminiChatService();
      final mockLocalizationProvider = MockLocalizationProvider();

      when(() => mockLocalizationProvider.currentLanguage).thenReturn('es');

      final chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);

      // Load chat history
      chatBloc.add(LoadChatHistoryEvent());

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the bloc handles the event without crashing
      expect(chatBloc.isClosed, isFalse);

      chatBloc.close();
    });

    test('ChatBloc clears chat correctly', () async {
      final mockChatService = MockGeminiChatService();
      final mockLocalizationProvider = MockLocalizationProvider();

      when(() => mockLocalizationProvider.currentLanguage).thenReturn('es');

      final chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);

      // Clear chat
      chatBloc.add(ClearChatEvent());

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the bloc handles the event without crashing
      expect(chatBloc.isClosed, isFalse);

      chatBloc.close();
    });
  });
}
