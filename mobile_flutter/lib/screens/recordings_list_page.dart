import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/recordings_provider.dart';

class RecordingsListPage extends ConsumerWidget {
  const RecordingsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingsAsync = ref.watch(recordingsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VoxaNote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: recordingsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No recordings yet. Tap the mic to start.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(recordingsListProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final rec = items[index];
                final duration =
                    Duration(seconds: rec.durationSec.clamp(0, 24 * 3600));
                final subtitle = rec.summary.bulletSummary.isNotEmpty
                    ? rec.summary.bulletSummary.first
                    : rec.transcriptText ?? '';
                return ListTile(
                  title: Text(rec.summary.title),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  ),
                  onTap: () =>
                      context.push('/recordings/${rec.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cannot connect to server',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure the backend server is running on port 4000.\n\n'
                  'To start the backend:\n'
                  'cd server && npm install && npm run dev\n\n'
                  'Error: ${e.toString().split('\n').first}',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref.refresh(recordingsListProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/record'),
        child: const Icon(Icons.mic),
      ),
    );
  }
}


