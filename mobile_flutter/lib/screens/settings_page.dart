import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _maxSecondsController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _maxSecondsController = TextEditingController();
    _maxSecondsController.addListener(() {
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
    });
    // Initialize controller after first frame when provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settings = ref.read(settingsProvider);
        _maxSecondsController.text = settings.maxRecordingSeconds.toString();
        _hasUnsavedChanges = false;
      }
    });
  }

  @override
  void dispose() {
    _maxSecondsController.dispose();
    super.dispose();
  }

  void _saveMaxSeconds() {
    final value = _maxSecondsController.text.trim();
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0) {
      ref.read(settingsProvider.notifier).updateMaxRecordingSeconds(parsed);
      setState(() {
        _hasUnsavedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Reset to current value if invalid
      final current = ref.read(settingsProvider).maxRecordingSeconds;
      _maxSecondsController.text = current.toString();
      setState(() {
        _hasUnsavedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Update controller if settings change externally (but not if user is editing)
    final currentText = _maxSecondsController.text;
    final settingsText = settings.maxRecordingSeconds.toString();
    if (currentText != settingsText && !_hasUnsavedChanges) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasUnsavedChanges) {
          _maxSecondsController.text = settingsText;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_hasUnsavedChanges)
            TextButton(
              onPressed: _saveMaxSeconds,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('Max recording length (seconds)'),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _maxSecondsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixIcon: _hasUnsavedChanges
                          ? IconButton(
                              icon: const Icon(Icons.check, size: 20),
                              onPressed: _saveMaxSeconds,
                              tooltip: 'Save',
                            )
                          : null,
                    ),
                    onFieldSubmitted: (_) => _saveMaxSeconds(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Upload on Wi‑Fi only'),
              value: settings.wifiOnlyUpload,
              onChanged: (v) async {
                await ref
                    .read(settingsProvider.notifier)
                    .updateWifiOnlyUpload(v);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Auth',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'MVP is single-user by default. Multi-user auth can be added later without changing the core flows.',
            ),
          ],
        ),
      ),
    );
  }
}


