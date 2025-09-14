import 'package:equatable/equatable.dart';
import '../../models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoading(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatSuccess extends ChatState {
  final List<ChatMessage> messages;

  const ChatSuccess(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final List<ChatMessage> messages;
  final String error;

  const ChatError(this.messages, this.error);

  @override
  List<Object?> get props => [messages, error];
}
