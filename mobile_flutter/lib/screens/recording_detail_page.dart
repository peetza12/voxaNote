import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../providers/recordings_provider.dart';
import '../services/api_client.dart';

class RecordingDetailPage extends ConsumerStatefulWidget {
  const RecordingDetailPage({super.key, required this.recordingId});

  final String recordingId;

  @override
  ConsumerState<RecordingDetailPage> createState() =>
      _RecordingDetailPageState();
}

class _RecordingDetailPageState extends ConsumerState<RecordingDetailPage> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordingAsync =
        ref.watch(recordingDetailProvider(widget.recordingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () =>
                context.push('/recordings/${widget.recordingId}/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: recordingAsync.when(
        data: (rec) {
          _player.setUrl(rec.storageUrl);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec.summary.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildPlayer(rec),
                  const SizedBox(height: 24),
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...rec.summary.bulletSummary
                      .map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $b'),
                          )),
                  const SizedBox(height: 16),
                  if (rec.summary.actionItems.isNotEmpty) ...[
                    Text(
                      'Action items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...rec.summary.actionItems
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $a'),
                            )),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Transcript',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(rec.transcriptText ?? 'Transcription not ready yet.'),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('Failed to load recording: $e'),
        ),
      ),
    );
  }

  Widget _buildPlayer(record) {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        return Row(
          children: [
            IconButton.filled(
              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (playing) {
                  _player.pause();
                } else {
                  _player.play();
                }
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snap) {
                  final pos = snap.data ?? Duration.zero;
                  final total = _player.duration ?? Duration.zero;
                  final value = total.inMilliseconds == 0
                      ? 0.0
                      : pos.inMilliseconds / total.inMilliseconds;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: value.clamp(0.0, 1.0),
                        onChanged: (v) {
                          final target = Duration(
                            milliseconds:
                                (total.inMilliseconds * v).toInt(),
                          );
                          _player.seek(target);
                        },
                      ),
                      Text(
                        '${_fmt(pos)} / ${_fmt(total)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _fmt(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text(
          'Are you sure you want to delete this recording? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final api = ref.read(apiClientProvider);
        await api.deleteRecording(widget.recordingId);
        
        // Refresh the list and go back
        await ref.read(recordingsListProvider.notifier).refresh();
        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete recording: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}


