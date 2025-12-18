import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voxa_note_mobile/providers/chat_provider.dart';
import 'package:voxa_note_mobile/services/api_client.dart';
import 'package:voxa_note_mobile/models/recording_models.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<ChatAnswer> askQuestion({
    required String recordingId,
    required String question,
  }) async {
    return ChatAnswer(
      answer: 'Test answer for "$question"',
      citations: const [],
    );
  }
}

void main() {
  test('chat provider appends messages and sets lastAnswer', () async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(_FakeApiClient()),
      ],
    );

    addTearDown(container.dispose);

    final notifier = container.read(chatProvider('rec-1').notifier);

    await notifier.ask('What was discussed?');

    final state = container.read(chatProvider('rec-1'));
    expect(state.messages.length, 2);
    expect(state.lastAnswer, isNotNull);
    expect(state.lastAnswer!.answer, contains('What was discussed?'));
  });
}


