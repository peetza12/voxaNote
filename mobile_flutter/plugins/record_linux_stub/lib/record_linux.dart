library record_linux;

import 'dart:async';
import 'dart:typed_data';

import 'package:record_platform_interface/record_platform_interface.dart';

/// Minimal stub Linux implementation just to satisfy the interface.
///
/// This app does not target Linux, so none of these methods are expected to run
/// at runtime on Android/iOS. They are safe no-op / error stubs to silence
/// compile-time interface errors from the upstream package.
class RecordLinux extends RecordPlatform {
  @override
  Future<void> dispose(String recorderId) async {
    // No-op for stub.
  }

  @override
  Future<void> start(
    String recorderId,
    RecordConfig config, {
    String? path,
  }) async {
    throw UnimplementedError('start is not implemented on Linux stub.');
  }

  @override
  Future<Stream<Uint8List>> startStream(
    String recorderId,
    RecordConfig config,
  ) async {
    throw UnimplementedError('startStream is not implemented on Linux stub.');
  }

  @override
  Future<String?> stop(String recorderId) async {
    throw UnimplementedError('stop is not implemented on Linux stub.');
  }

  @override
  Future<bool> isRecording(String recorderId) async {
    return false;
  }

  @override
  Future<bool> isPaused(String recorderId) async {
    return false;
  }

  @override
  Future<bool> hasPermission(String recorderId) async {
    // Permissions are handled by Android/iOS implementations in this app.
    return true;
  }

  @override
  Future<List<InputDevice>> listInputDevices(String recorderId) async {
    return <InputDevice>[];
  }

  @override
  Future<Amplitude> getAmplitude(String recorderId) async {
    return Amplitude(current: 0, max: 0);
  }

  @override
  Future<bool> isEncoderSupported(
    String recorderId,
    AudioEncoder encoder,
  ) async {
    return false;
  }
}
