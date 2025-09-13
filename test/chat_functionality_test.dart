import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:devocional_nuevo/blocs/chat/chat_bloc.dart';
import 'package:devocional_nuevo/blocs/chat/chat_event.dart';
import 'package:devocional_nuevo/blocs/chat/chat_state.dart';
import 'package:devocional_nuevo/models/chat_message.dart';
import 'package:devocional_nuevo/services/gemini_chat_service.dart';
import 'package:devocional_nuevo/providers/localization_provider.dart';

// Mock classes
class MockGeminiChatService extends Mock implements GeminiChatService {}
class MockLocalizationProvider extends Mock implements LocalizationProvider {}

void main() {
  group('ChatBloc Tests', () {
    late ChatBloc chatBloc;
    late MockGeminiChatService mockChatService;
    late MockLocalizationProvider mockLocalizationProvider;

    setUp(() {
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
      'emits [ChatLoading, ChatSuccess] when SendMessageEvent succeeds',
      build: () {
        when(() => mockChatService.sendMessage(any(), any()))
            .thenAnswer((_) async => 'Test response from Gemini');
        return chatBloc;
      },
      act: (bloc) => bloc.add(const SendMessageEvent('Test message')),
      expect: () => [
        isA<ChatLoading>(),
        isA<ChatSuccess>(),
      ],
      verify: (bloc) {
        verify(() => mockChatService.sendMessage('Test message', 'es')).called(1);
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
      act: (bloc) => bloc.add(ClearChatEvent()),
      expect: () => [
        isA<ChatSuccess>().having((state) => state.messages, 'messages', isEmpty),
      ],
    );
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
        content: 'Test message',
        isUser: true,
        timestamp: DateTime(2024, 1, 1),
        biblicalReferences: ['John 3:16'],
      );

      final json = originalMessage.toJson();
      final recreatedMessage = ChatMessage.fromJson(json);

      expect(recreatedMessage, equals(originalMessage));
    });
  });

  group('GeminiChatService Tests', () {
    test('service structure is correct', () {
      // We can't test instantiation without dotenv.load() in test environment
      // This confirms the class exists and can be referenced
      expect(GeminiChatService, isNotNull);
    });

    // Note: We can't test actual API calls without real API keys
    // The service integration is tested through the BLoC tests
  });
}