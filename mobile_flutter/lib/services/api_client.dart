import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/recording_models.dart';

// Get API base URL from environment or use smart defaults
String get apiBaseUrl {
  // Check for environment variable first
  const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (envUrl.isNotEmpty) {
    return envUrl;
  }
  
  // For iOS/Android physical devices, use network IP instead of localhost
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    // Use your Mac's network IP - update this if your IP changes
    return 'http://192.168.5.89:4000';
  }
  
  // Default to localhost for emulators/simulators/web
  return 'http://localhost:4000';
}

class ApiClient {
  ApiClient() : _dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl, // Uses getter that auto-detects platform
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  final Dio _dio;

  Future<(Recording, String)> createRecording({
    required String title,
    required int durationSec,
  }) async {
    final response = await _dio.post(
      '/recordings',
      data: {
        'title': title,
        'durationSec': durationSec,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final rec = Recording.fromJson(data['recording'] as Map<String, dynamic>);
    final uploadUrl = data['uploadUrl'] as String;
    return (rec, uploadUrl);
  }

  Future<List<Recording>> listRecordings() async {
    final response = await _dio.get('/recordings');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Recording.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Recording> getRecording(String id) async {
    final response = await _dio.get('/recordings/$id');
    return Recording.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> triggerProcessing(String id) async {
    await _dio.post('/recordings/$id/process');
  }

  Future<List<ChatMessage>> getChatMessages(String recordingId) async {
    final response = await _dio.get('/recordings/$recordingId/messages');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatAnswer> askQuestion({
    required String recordingId,
    required String question,
  }) async {
    final response = await _dio.post(
      '/recordings/$recordingId/chat',
      data: {'question': question},
    );
    return ChatAnswer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteRecording(String id) async {
    await _dio.delete('/recordings/$id');
  }

  Future<void> uploadAudio({
    required String uploadUrl,
    required String filePath,
  }) async {
    // Direct upload to signed S3 URL using http package for more control
    // S3 presigned URLs require exact header matching - use http for precise control
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    
    final uri = Uri.parse(uploadUrl);
    
    // Extract Content-Type from signed URL query params if present, otherwise use default
    final contentType = uri.queryParameters['Content-Type'] ?? 'audio/m4a';
    
    final response = await http.put(
      uri,
      body: bytes,
      headers: {
        'Content-Type': contentType,
        'Content-Length': bytes.length.toString(),
      },
    );
    
    if (response.statusCode >= 400) {
      throw Exception(
        'Upload failed: ${response.statusCode} ${response.reasonPhrase}\n'
        'Response: ${response.body}',
      );
    }
  }
}


