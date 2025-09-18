import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:devocional_nuevo/blocs/chat/chat_bloc.dart';
import 'package:devocional_nuevo/blocs/chat/chat_state.dart';
import 'package:devocional_nuevo/services/gemini_chat_service.dart';
import 'package:devocional_nuevo/providers/localization_provider.dart';
import 'package:devocional_nuevo/widgets/chat_floating_button.dart';
import 'package:devocional_nuevo/widgets/chat_overlay.dart';
import 'package:devocional_nuevo/widgets/chat_message_widget.dart';
import 'package:devocional_nuevo/models/chat_message.dart';

// Mock classes
class MockGeminiChatService extends Mock implements GeminiChatService {}

class MockLocalizationProvider extends Mock implements LocalizationProvider {}

class MockChatBloc extends Mock implements ChatBloc {}

void main() {
  group('Chat UI Widget Tests', () {
    late MockGeminiChatService mockChatService;
    late MockLocalizationProvider mockLocalizationProvider;

    setUp(() {
      mockChatService = MockGeminiChatService();
      mockLocalizationProvider = MockLocalizationProvider();

      when(() => mockLocalizationProvider.currentLanguage).thenReturn('es');
    });

    testWidgets('ChatFloatingButton renders correctly',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatFloatingButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      expect(pressed, isTrue);
    });

    testWidgets('ChatMessageWidget renders user message correctly',
        (WidgetTester tester) async {
      final userMessage = ChatMessage(
        id: '1',
        content: 'Hello, this is a test message',
        isUser: true,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: userMessage),
          ),
        ),
      );

      expect(find.text('Hello, this is a test message'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('ChatMessageWidget renders bot message correctly',
        (WidgetTester tester) async {
      final botMessage = ChatMessage(
        id: '2',
        content: 'This is a response from the biblical assistant',
        isUser: false,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: botMessage),
          ),
        ),
      );

      expect(find.text('This is a response from the biblical assistant'),
          findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('ChatOverlay renders correctly with BLoC',
        (WidgetTester tester) async {
      final chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: chatBloc,
            child: const Scaffold(
              body: ChatOverlay(),
            ),
          ),
        ),
      );

      expect(find.text('Biblical Assistant'), findsOneWidget);
      expect(
          find.text(
              'Ask me anything about the Bible!\nI\'m here to help you grow spiritually.'),
          findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);

      chatBloc.close();
    });

    testWidgets('ChatOverlay shows loading state correctly',
        (WidgetTester tester) async {
      final chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);

      // Add a user message to trigger loading state
      final userMessage = ChatMessage(
        id: '1',
        content: 'Test message',
        isUser: true,
        timestamp: DateTime.now(),
      );

      // Emit loading state manually
      chatBloc.emit(ChatLoading([userMessage]));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: chatBloc,
            child: const Scaffold(
              body: ChatOverlay(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Test message'), findsOneWidget);
      expect(find.text('Thinking...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      chatBloc.close();
    });

    testWidgets('ChatOverlay text input works correctly',
        (WidgetTester tester) async {
      final chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: chatBloc,
            child: const Scaffold(
              body: ChatOverlay(),
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Test input message');
      await tester.pump();

      expect(find.text('Test input message'), findsOneWidget);

      chatBloc.close();
    });
  });

  group('Chat Integration Tests', () {
    testWidgets('Complete chat flow integration', (WidgetTester tester) async {
      final mockChatService = MockGeminiChatService();
      final mockLocalizationProvider = MockLocalizationProvider();

      when(() => mockLocalizationProvider.currentLanguage).thenReturn('en');
      when(() => mockChatService.sendMessage(any(), any())).thenAnswer(
          (_) async => 'Peace be with you, according to John 14:27');

      final chatBloc = ChatBloc(mockChatService, mockLocalizationProvider);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: mockLocalizationProvider),
              BlocProvider<ChatBloc>.value(value: chatBloc),
            ],
            child: Builder(
              builder: (context) => Scaffold(
                floatingActionButton: ChatFloatingButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (bottomSheetContext) => BlocProvider.value(
                        value: chatBloc,
                        child: const ChatOverlay(),
                      ),
                    );
                  },
                ),
                body: const Center(child: Text('Main App')),
              ),
            ),
          ),
        ),
      );

      // Verify main page renders
      expect(find.text('Main App'), findsOneWidget);
      expect(find.byType(ChatFloatingButton), findsOneWidget);

      // Tap chat button to open overlay
      await tester.tap(find.byType(ChatFloatingButton));
      await tester.pumpAndSettle();

      // Verify chat overlay opens
      expect(find.text('Biblical Assistant'), findsOneWidget);
      expect(
          find.text(
              'Ask me anything about the Bible!\nI\'m here to help you grow spiritually.'),
          findsOneWidget);

      chatBloc.close();
    });
  });
}
