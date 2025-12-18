import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recording_models.dart';
import '../services/api_client.dart';
import 'recordings_provider.dart';

class ChatState {
  final List<(String role, String content)> messages;
  final bool isLoading;
  final ChatAnswer? lastAnswer;
  final String? error;

  ChatState({
    required this.messages,
    required this.isLoading,
    required this.lastAnswer,
    required this.error,
  });

  factory ChatState.initial() => ChatState(
        messages: const [],
        isLoading: false,
        lastAnswer: null,
        error: null,
      );

  ChatState copyWith({
    List<(String role, String content)>? messages,
    bool? isLoading,
    ChatAnswer? lastAnswer,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      error: error,
    );
  }
}

final chatProvider =
    NotifierProvider.family<ChatNotifier, ChatState, String>(ChatNotifier.new);

class ChatNotifier extends FamilyNotifier<ChatState, String> {
  bool _historyLoaded = false;

  @override
  ChatState build(String arg) {
    // Load history asynchronously when provider is first created
    if (!_historyLoaded) {
      _historyLoaded = true;
      Future.microtask(() => loadHistory());
    }
    return ChatState.initial();
  }

  Future<void> loadHistory() async {
    final recordingId = arg;
    try {
      final api = ref.read(apiClientProvider);
      final messages = await api.getChatMessages(recordingId);
      
      // Convert ChatMessage to (role, content) tuples for display
      final messageTuples = messages
          .map((m) => (m.role, m.content))
          .toList();
      
      state = state.copyWith(
        messages: messageTuples,
        error: null,
      );
    } catch (e) {
      // If loading history fails, just keep current state
      // Don't show error for history loading failures
    }
  }

  Future<void> ask(String question) async {
    final recordingId = arg;
    state = state.copyWith(
      isLoading: true,
      messages: [...state.messages, ('user', question)],
      error: null,
    );
    try {
      final api = ref.read(apiClientProvider);
      final answer = await api.askQuestion(
        recordingId: recordingId,
        question: question,
      );
      
      // Reload history to get the latest messages from the server
      // This ensures we have the exact messages as stored in the database
      await loadHistory();
      
      state = state.copyWith(
        isLoading: false,
        lastAnswer: answer,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}


