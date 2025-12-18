import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recording_models.dart';
import '../services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final recordingsListProvider =
    AsyncNotifierProvider<RecordingsListNotifier, List<Recording>>(
  RecordingsListNotifier.new,
);

class RecordingsListNotifier extends AsyncNotifier<List<Recording>> {
  @override
  FutureOr<List<Recording>> build() async {
    final api = ref.read(apiClientProvider);
    final list = await api.listRecordings();
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      return api.listRecordings();
    });
  }
}

final recordingDetailProvider =
    AsyncNotifierProvider.family<RecordingDetailNotifier, Recording, String>(
  RecordingDetailNotifier.new,
);

class RecordingDetailNotifier extends FamilyAsyncNotifier<Recording, String> {
  @override
  FutureOr<Recording> build(String arg) async {
    final api = ref.read(apiClientProvider);
    return api.getRecording(arg);
  }

  Future<void> refresh() async {
    final id = arg;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      return api.getRecording(id);
    });
  }
}


