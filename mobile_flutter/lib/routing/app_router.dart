import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/recordings_list_page.dart';
import '../screens/record_page.dart';
import '../screens/recording_detail_page.dart';
import '../screens/chat_page.dart';
import '../screens/settings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'recordings',
        builder: (context, state) => const RecordingsListPage(),
      ),
      GoRoute(
        path: '/record',
        name: 'record',
        builder: (context, state) => const RecordPage(),
      ),
      GoRoute(
        path: '/recordings/:id',
        name: 'recordingDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RecordingDetailPage(recordingId: id);
        },
      ),
      GoRoute(
        path: '/recordings/:id/chat',
        name: 'chat',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatPage(recordingId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});


