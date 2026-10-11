import 'package:intl/intl.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int colorIndex;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.colorIndex = 0,
  });

  // Convert Note instance to Map for SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'color_index': colorIndex,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Create Note instance from SQLite Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
      colorIndex: (map['color_index'] as int?) ?? 0,
    );
  }

  // Helper copyWith method
  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? colorIndex,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  // Format creation time nicely (e.g., 11/10/2026 • 11:45)
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0 && now.day == createdAt.day) {
      return 'Hôm nay, ${DateFormat('HH:mm').format(createdAt)}';
    } else if (difference.inDays <= 1 && now.day - createdAt.day == 1) {
      return 'Hôm qua, ${DateFormat('HH:mm').format(createdAt)}';
    } else {
      return DateFormat('dd/MM/yyyy • HH:mm').format(createdAt);
    }
  }

  // Short snippet preview for note content
  String get snippet {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 'Không có nội dung';
    return trimmed;
  }
}
