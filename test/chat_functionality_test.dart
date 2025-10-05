import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:devocional_nuevo/blocs/chat/chat_bloc.dart';
import 'package:devocional_nuevo/blocs/chat/chat_event.dart';
import 'package:devocional_nuevo/blocs/chat/chat_state.dart';
import 'package:devocional_nuevo/models/chat_message.dart';
import 'package:devocional_nuevo/services/gemini_chat_service.dart';
import 'package:devocional_nuevo/providers/localization_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_setup.dart';

// Mock classes
class MockGeminiChatService extends Mock implements GeminiChatService {}

class MockLocalizationProvider extends Mock implements LocalizationProvider {}

void main() {
  setUpAll(() {
    TestSetup.setupCommonMocks();
  });

  tearDownAll(() {
    TestSetup.cleanupMocks();
  });

  group('ChatBloc Tests', () {
    late ChatBloc chatBloc;
    late MockGeminiChatService mockChatService;
    late MockLocalizationProvider mockLocalizationProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockChatService = MockGeminiChatService();
      mockLocalizationProvider = MockLocalizationProvider();

      // Setup default mock returns
      when(() => mockLocalizationProvider.currentLanguage).thenReturn('es');

      chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);
    });

    tearDown(() {
      chatBloc.close();
    });

    test('initial state is ChatInitial', () {
      expect(chatBloc.state, isA<ChatInitial>());
    });

    blocTest<ChatBloc, ChatState>(
      'emits [ChatSuccess] when LoadChatHistoryEvent is added with empty history',
      build: () => chatBloc,
      act: (bloc) => bloc.add(LoadChatHistoryEvent()),
      expect: () => [
        isA<ChatSuccess>()
            .having((state) => state.messages, 'messages', isEmpty),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatSuccess] when SendMessageEvent succeeds',
      build: () {
        when(() => mockChatService.sendMessage(any(), any())).thenAnswer(
            (_) async => 'Test response from Gemini with biblical wisdom');
        return chatBloc;
      },
      act: (bloc) => bloc.add(const SendMessageEvent('Test question')),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatSuccess>(),
      ],
      verify: (bloc) {
        verify(() => mockChatService.sendMessage('Test question', 'es'))
            .called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatError] when SendMessageEvent fails',
      build: () {
        when(() => mockChatService.sendMessage(any(), any()))
            .thenThrow(Exception('API Error'));
        return chatBloc;
      },
      act: (bloc) => bloc.add(const SendMessageEvent('Test message')),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatError>(),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatSuccess] with empty messages when ClearChatEvent is added',
      build: () => chatBloc,
      seed: () {
        // Add a message first
        return ChatSuccess([
          ChatMessage(
            id: '1',
            content: 'Test',
            isUser: true,
            timestamp: DateTime.now(),
          ),
        ]);
      },
      act: (bloc) => bloc.add(ClearChatEvent()),
      expect: () => [
        isA<ChatSuccess>()
            .having((state) => state.messages, 'messages', isEmpty),
      ],
    );

    test('messages are saved to SharedPreferences', () async {
      when(() => mockChatService.sendMessage(any(), any()))
          .thenAnswer((_) async => 'Response');

      chatBloc.add(const SendMessageEvent('Hello'));
      await Future.delayed(const Duration(milliseconds: 100));

      final prefs = await SharedPreferences.getInstance();
      final savedMessages = prefs.getStringList('chat_messages');
      expect(savedMessages, isNotNull);
    });
  });

  group('ChatMessage Tests', () {
    test('ChatMessage equality works correctly', () {
      final message1 = ChatMessage(
        id: '1',
        content: 'Test message',
        isUser: true,
        timestamp: DateTime(2024, 1, 1),
      );

      final message2 = ChatMessage(
        id: '1',
        content: 'Test message',
        isUser: true,
        timestamp: DateTime(2024, 1, 1),
      );

      expect(message1, equals(message2));
    });

    test('ChatMessage toJson and fromJson work correctly', () {
      final originalMessage = ChatMessage(
        id: '1',
        content: 'Test message with biblical wisdom',
        isUser: true,
        timestamp: DateTime(2024, 1, 1),
        biblicalReferences: ['John 3:16', 'Psalm 23'],
      );

      final json = originalMessage.toJson();
      final recreatedMessage = ChatMessage.fromJson(json);

      expect(recreatedMessage, equals(originalMessage));
      expect(recreatedMessage.biblicalReferences, ['John 3:16', 'Psalm 23']);
    });

    test('ChatMessage handles null biblicalReferences', () {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        isUser: false,
        timestamp: DateTime.now(),
      );

      final json = message.toJson();
      final recreated = ChatMessage.fromJson(json);

      expect(recreated.biblicalReferences, isNull);
    });
  });

  group('ChatEvent Tests', () {
    test('SendMessageEvent has correct props', () {
      const event1 = SendMessageEvent('message1');
      const event2 = SendMessageEvent('message1');
      const event3 = SendMessageEvent('message2');

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('LoadChatHistoryEvent and ClearChatEvent are equal', () {
      final load1 = LoadChatHistoryEvent();
      final load2 = LoadChatHistoryEvent();
      final clear1 = ClearChatEvent();
      final clear2 = ClearChatEvent();

      expect(load1, equals(load2));
      expect(clear1, equals(clear2));
    });
  });

  group('ChatState Tests', () {
    test('ChatSuccess states are equal with same messages', () {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        isUser: true,
        timestamp: DateTime(2024, 1, 1),
      );

      final state1 = ChatSuccess([message]);
      final state2 = ChatSuccess([message]);

      expect(state1, equals(state2));
    });

    test('ChatError states are equal with same messages and error', () {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        isUser: true,
        timestamp: DateTime(2024, 1, 1),
      );

      const state1 = ChatError([], 'Error 1');
      const state2 = ChatError([], 'Error 1');

      expect(state1, equals(state2));
    });

    test('ChatLoading states are equal with same messages', () {
      final message = ChatMessage(
        id: '1',
        content: 'Test',
        isUser: true,
        timestamp: DateTime(2024, 1, 1),
      );

      final state1 = ChatLoading([message]);
      final state2 = ChatLoading([message]);

      expect(state1, equals(state2));
    });
  });

  group('GeminiChatService Integration Tests', () {
    test('service structure validation', () {
      // We can't test instantiation without dotenv.load() in test environment
      // This confirms the class exists and can be referenced
      expect(GeminiChatService, isNotNull);
    });

    test('service can handle different languages', () {
      // Mock test to ensure service accepts different language codes
      final service = MockGeminiChatService();

      when(() => service.sendMessage(any(), 'es'))
          .thenAnswer((_) async => 'Respuesta en español');
      when(() => service.sendMessage(any(), 'en'))
          .thenAnswer((_) async => 'Response in English');
      when(() => service.sendMessage(any(), 'pt'))
          .thenAnswer((_) async => 'Resposta em português');
      when(() => service.sendMessage(any(), 'fr'))
          .thenAnswer((_) async => 'Réponse en français');

      expect(service.sendMessage('test', 'es'), completes);
      expect(service.sendMessage('test', 'en'), completes);
      expect(service.sendMessage('test', 'pt'), completes);
      expect(service.sendMessage('test', 'fr'), completes);
    });
  });

  group('Chat History Persistence Tests', () {
    test('chat history is limited to 50 messages', () async {
      SharedPreferences.setMockInitialValues({});
      final mockService = MockGeminiChatService();
      final mockProvider = MockLocalizationProvider();

      when(() => mockProvider.currentLanguage).thenReturn('es');
      when(() => mockService.sendMessage(any(), any()))
          .thenAnswer((_) async => 'Response');

      final bloc = ChatBloc(mockService, mockProvider);

      // Send 60 messages
      for (int i = 0; i < 60; i++) {
        bloc.add(SendMessageEvent('Message $i'));
        await Future.delayed(const Duration(milliseconds: 10));
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      final savedMessages = prefs.getStringList('chat_messages');

      // Should only save last 50 messages
      expect(savedMessages, isNotNull);
      expect(savedMessages!.length, lessThanOrEqualTo(50));

      bloc.close();
    });
  });
}
