class RecordingSummary {
  final String title;
  final List<String> bulletSummary;
  final List<String> actionItems;
  final List<String> topics;
  final List<String> keyEntities;
  final List<String> keyDates;

  RecordingSummary({
    required this.title,
    required this.bulletSummary,
    required this.actionItems,
    required this.topics,
    required this.keyEntities,
    required this.keyDates,
  });

  factory RecordingSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RecordingSummary(
        title: 'Untitled',
        bulletSummary: const [],
        actionItems: const [],
        topics: const [],
        keyEntities: const [],
        keyDates: const [],
      );
    }
    List<String> _strings(dynamic v) =>
        (v as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    return RecordingSummary(
      title: json['title']?.toString() ?? 'Untitled',
      bulletSummary: _strings(json['bullet_summary']),
      actionItems: _strings(json['action_items']),
      topics: _strings(json['topics']),
      keyEntities: _strings(json['key_entities']),
      keyDates: _strings(json['key_dates']),
    );
  }
}

class Recording {
  final String id;
  final String title;
  final DateTime createdAt;
  final int durationSec;
  final String storageUrl;
  final String? playbackUrl; // Signed URL for audio playback
  final String? transcriptText;
  final RecordingSummary summary;
  final String status;

  Recording({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.durationSec,
    required this.storageUrl,
    this.playbackUrl,
    required this.transcriptText,
    required this.summary,
    required this.status,
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] as String,
      title: json['summary_json']?['title']?.toString() ??
          json['title']?.toString() ??
          'Untitled',
      createdAt: DateTime.parse(json['created_at'] as String),
      durationSec: json['duration_sec'] as int,
      storageUrl: json['storage_url'] as String,
      playbackUrl: json['playback_url'] as String?,
      transcriptText: json['transcript_text'] as String?,
      summary: RecordingSummary.fromJson(
          json['summary_json'] as Map<String, dynamic>?),
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

class ChatCitation {
  final String text;
  final double? startSec;
  final double? endSec;

  ChatCitation({
    required this.text,
    this.startSec,
    this.endSec,
  });

  factory ChatCitation.fromJson(Map<String, dynamic> json) {
    // Handle both string and numeric values from database
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }
    
    return ChatCitation(
      text: json['text']?.toString() ?? '',
      startSec: _parseDouble(json['start_sec']),
      endSec: _parseDouble(json['end_sec']),
    );
  }
}

class ChatMessage {
  final String id;
  final String recordingId;
  final String role;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.recordingId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      recordingId: json['recording_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ChatAnswer {
  final String answer;
  final List<ChatCitation> citations;

  ChatAnswer({
    required this.answer,
    required this.citations,
  });

  factory ChatAnswer.fromJson(Map<String, dynamic> json) {
    final citationsJson = json['citations'] as List<dynamic>? ?? [];
    return ChatAnswer(
      answer: json['answer']?.toString() ?? '',
      citations: citationsJson
          .map((e) => ChatCitation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}


