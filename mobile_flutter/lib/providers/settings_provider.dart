import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final int maxRecordingSeconds;
  final bool wifiOnlyUpload;

  SettingsState({
    required this.maxRecordingSeconds,
    required this.wifiOnlyUpload,
  });

  SettingsState copyWith({
    int? maxRecordingSeconds,
    bool? wifiOnlyUpload,
  }) {
    return SettingsState(
      maxRecordingSeconds: maxRecordingSeconds ?? this.maxRecordingSeconds,
      wifiOnlyUpload: wifiOnlyUpload ?? this.wifiOnlyUpload,
    );
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  static const _maxSecondsKey = 'max_recording_seconds';
  static const _wifiOnlyKey = 'wifi_only_upload';
  bool _loaded = false;

  @override
  SettingsState build() {
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    return SettingsState(maxRecordingSeconds: 600, wifiOnlyUpload: true);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final maxSec = prefs.getInt(_maxSecondsKey) ?? 600;
    final wifiOnly = prefs.getBool(_wifiOnlyKey) ?? true;
    state = SettingsState(
      maxRecordingSeconds: maxSec,
      wifiOnlyUpload: wifiOnly,
    );
  }

  Future<void> updateMaxRecordingSeconds(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxSecondsKey, value);
    state = state.copyWith(maxRecordingSeconds: value);
  }

  Future<void> updateWifiOnlyUpload(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wifiOnlyKey, value);
    state = state.copyWith(wifiOnlyUpload: value);
  }
}


