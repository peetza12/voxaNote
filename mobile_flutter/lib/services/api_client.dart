import 'dart:io';

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
    // Direct upload to signed S3 URL using http package for more control
    // S3 presigned URLs require exact header matching - use http for precise control
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $filePath');
    }
    
    final bytes = await file.readAsBytes();
    final uri = Uri.parse(uploadUrl);
    
    // S3 presigned URLs are very sensitive to headers
    // The signed URL shows X-Amz-SignedHeaders=host, meaning ONLY host is signed
    // We should NOT send Content-Type if it's not in the signed headers
    // Content-Length is usually safe to send
    final headers = <String, String>{
      'Content-Length': bytes.length.toString(),
    };
    
    // Only add Content-Type if the signed URL includes it in signed headers
    // For Railway S3, the signed URL only signs 'host', so we skip Content-Type
    // This prevents signature mismatch errors
    
    final response = await http.put(
      uri,
      body: bytes,
      headers: headers,
    );
    
    if (response.statusCode >= 400) {
      throw Exception(
        'Upload failed: ${response.statusCode} ${response.reasonPhrase}\n'
        'Response: ${response.body}\n'
        'URL: ${uri.toString().substring(0, uri.toString().indexOf('?'))}...',
      );
    }
  }
}


