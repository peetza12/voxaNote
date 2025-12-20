import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/recording_models.dart';

// Get API base URL from environment or use smart defaults
String get apiBaseUrl {
  // Priority 1: Check for environment variable (set at build time)
  const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (envUrl.isNotEmpty) {
    return envUrl;
  }
  
  // Priority 2: Check for production URL (set at build time for release builds)
  const prodUrl = String.fromEnvironment('PROD_API_BASE_URL', defaultValue: '');
  if (prodUrl.isNotEmpty) {
    return prodUrl;
  }
  
  // Priority 3: Production default (Railway backend)
  // This ensures the app works in production without needing build flags
  return 'https://voxanote-production.up.railway.app';
  
  // Development fallbacks (commented out - uncomment for local development)
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   return 'http://192.168.5.89:4000';
  // }
  // return 'http://localhost:4000';
}

class ApiClient {
  ApiClient() : _dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl, // Uses getter that auto-detects platform
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
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
    // Use http package's low-level API for maximum control
    // S3 presigned URLs require EXACT header matching - only 'host' is signed
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $filePath');
    }
    
    final bytes = await file.readAsBytes();
    final uri = Uri.parse(uploadUrl);
    
    // Use http.Client with manual request construction for precise control
    final client = http.Client();
    try {
      // Create a raw request - this gives us complete control
      final request = http.Request('PUT', uri);
      request.bodyBytes = bytes;
      
      // Set ONLY Content-Length header (Railway S3 requires it)
      // DO NOT set Content-Type or any other headers - only 'host' is signed
      request.headers['Content-Length'] = bytes.length.toString();
      
      // Explicitly remove any headers that might have been set automatically
      request.headers.remove('Content-Type');
      request.headers.remove('User-Agent');
      request.headers.remove('Accept');
      request.headers.remove('Accept-Encoding');
      request.headers.remove('Connection');
      
      // Send the request
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 400) {
        throw Exception(
          'Upload failed: ${response.statusCode} ${response.reasonPhrase}\n'
          'Response: ${response.body}\n'
          'URL: ${uri.toString().substring(0, uri.toString().indexOf('?'))}...',
        );
      }
    } finally {
      client.close();
    }
  }
}


