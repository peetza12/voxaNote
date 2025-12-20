import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/recordings_provider.dart';
import '../services/api_client.dart';

class RecordingsListPage extends ConsumerStatefulWidget {
  const RecordingsListPage({super.key});

  @override
  ConsumerState<RecordingsListPage> createState() => _RecordingsListPageState();
}

class _RecordingsListPageState extends ConsumerState<RecordingsListPage> {
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recordings'),
        content: Text(
          'Delete ${_selectedIds.length} recording${_selectedIds.length > 1 ? 's' : ''}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final api = ref.read(apiClientProvider);
      for (final id in _selectedIds) {
        await api.deleteRecording(id);
      }
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
      // Refresh the list
      ref.read(recordingsListProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${_selectedIds.length} recording${_selectedIds.length > 1 ? 's' : ''}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingsAsync = ref.watch(recordingsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedIds.length} selected')
            : const Text('VoxaNote'),
        actions: [
          if (_isSelectionMode) ...[
            if (_selectedIds.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteSelected,
                tooltip: 'Delete selected',
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectionMode,
              tooltip: 'Cancel selection',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select recordings',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
          ],
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
                final isSelected = _selectedIds.contains(rec.id);
                return ListTile(
                  leading: _isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(rec.id),
                        )
                      : null,
                  title: Text(rec.summary.title),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: _isSelectionMode
                      ? null
                      : Text(
                          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        ),
                  selected: isSelected,
                  onTap: _isSelectionMode
                      ? () => _toggleSelection(rec.id)
                      : () => context.push('/recordings/${rec.id}'),
                  onLongPress: _isSelectionMode
                      ? null
                      : () {
                          setState(() {
                            _isSelectionMode = true;
                            _selectedIds.add(rec.id);
                          });
                        },
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
                  'Unable to connect to the production backend.\n\n'
                  'Please check your internet connection and try again.\n\n'
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


