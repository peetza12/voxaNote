import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../providers/recordings_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_client.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRecording = false;
  bool _isPaused = false;
  String? _filePath;
  bool _isUploading = false;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      setState(() {
        _error = 'Microphone permission is required.';
      });
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _filePath = path;
      _isRecording = true;
      _isPaused = false;
      _elapsedSeconds = 0;
      _error = null;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final settings = ref.read(settingsProvider);
      if (_elapsedSeconds >= settings.maxRecordingSeconds) {
        _stop();
        return;
      }
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  Future<void> _pause() async {
    await _recorder.pause();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resume() async {
    await _recorder.resume();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _filePath = path ?? _filePath;
    });
  }

  Future<void> _uploadAndProcess() async {
    if (_filePath == null) return;
    setState(() {
      _isUploading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final title = 'Recording ${DateTime.now().toLocal()}';
      final durationSec = _elapsedSeconds.clamp(1, 24 * 3600);
      final (recording, uploadUrl) = await api.createRecording(
        title: title,
        durationSec: durationSec,
      );

      await api.uploadAudio(uploadUrl: uploadUrl, filePath: _filePath!);
      await api.triggerProcessing(recording.id);

      // refresh list
      await ref.read(recordingsListProvider.notifier).refresh();
      if (mounted) {
        // Go back to home screen after successful upload
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _error = 'Upload failed: $e';
        _isUploading = false;
      });
      return;
    }
    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration =
        Duration(seconds: _elapsedSeconds.clamp(0, 24 * 3600).toInt());
    final fileInfo = _filePath != null
        ? File(_filePath!).existsSync()
            ? File(_filePath!).lengthSync()
            : 0
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            if (_filePath != null)
              Text(
                'File: ${(fileInfo / (1024 * 1024)).toStringAsFixed(2)} MB',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRecording && !_isPaused)
                  IconButton.filled(
                    iconSize: 48,
                    icon: const Icon(Icons.pause),
                    onPressed: _pause,
                  )
                else if (_isRecording && _isPaused)
                  IconButton.filled(
                    iconSize: 48,
                    icon: const Icon(Icons.play_arrow),
                    onPressed: _resume,
                  )
                else
                  IconButton.filled(
                    iconSize: 64,
                    icon: const Icon(Icons.mic),
                    onPressed: _start,
                  ),
                const SizedBox(width: 32),
                if (_isRecording)
                  IconButton(
                    iconSize: 48,
                    icon: const Icon(Icons.stop),
                    onPressed: _stop,
                  ),
              ],
            ),
            const SizedBox(height: 32),
            if (_filePath != null && !_isRecording)
              FilledButton.icon(
                onPressed: _isUploading ? null : _uploadAndProcess,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isUploading ? 'Uploading...' : 'Upload & Process'),
              ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ]
          ],
        ),
      ),
    );
  }
}


