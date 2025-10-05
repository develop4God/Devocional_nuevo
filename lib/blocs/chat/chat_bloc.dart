import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/gemini_chat_service.dart';
import '../../providers/localization_provider.dart';
import '../../models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiChatService _chatService;
  final LocalizationProvider _localizationProvider;
  List<ChatMessage> _messages = [];

  ChatBloc(this._chatService, this._localizationProvider)
      : super(ChatInitial()) {
    on<LoadChatHistoryEvent>(_onLoadHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatEvent>(_onClearChat);
  }

  Future<void> _onLoadHistory(
      LoadChatHistoryEvent event, Emitter<ChatState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList('chat_messages') ?? [];
      _messages = messagesJson
          .map((json) => ChatMessage.fromJson(jsonDecode(json)))
          .toList();
      emit(ChatSuccess(_messages));
    } catch (e) {
      emit(ChatError(_messages, 'Failed to load chat history'));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    emit(ChatLoading(_messages));

    try {
      final language = _localizationProvider.currentLanguage;
      final response = await _chatService.sendMessage(event.message, language);

      final botMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(botMessage);
      await _saveMessages();
      emit(ChatSuccess(_messages));
    } catch (e) {
      emit(ChatError(_messages, e.toString()));
    }
  }

  Future<void> _onClearChat(
      ClearChatEvent event, Emitter<ChatState> emit) async {
    _messages.clear();
    await _saveMessages();
    emit(ChatSuccess(_messages));
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages
          .take(50) // Keep only last 50 messages for performance
          .map((msg) => jsonEncode(msg.toJson()))
          .toList();
      await prefs.setStringList('chat_messages', messagesJson);
    } catch (e) {
      // Handle storage error silently
    }
  }
}
