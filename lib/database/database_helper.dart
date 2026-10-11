import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

class DatabaseHelper {
  static const _databaseName = "notes_app.db";
  static const _databaseVersion = 1;

  static const tableNotes = 'notes';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnContent = 'content';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';
  static const columnColorIndex = 'color_index';

  // Khóa lưu trữ cho Web (Chrome)
  static const _webStorageKey = 'web_notes_storage';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Khởi tạo bảng SQLite cho mobile (Android / iOS)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNotes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnColorIndex INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ===================== HELPER CHO WEB =====================
  Future<List<Note>> _getWebNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_webStorageKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded
          .map((item) => Note.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveWebNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final list = notes.map((n) => n.toMap()).toList();
    await prefs.setString(_webStorageKey, jsonEncode(list));
  }
  // ==========================================================

  // Thêm ghi chú mới (Insert Note)
  Future<int> insertNote(Note note) async {
    if (kIsWeb) {
      final notes = await _getWebNotes();
      final nextId = notes.isEmpty
          ? 1
          : (notes.map((n) => n.id ?? 0).reduce(max) + 1);
      final newNote = note.copyWith(id: nextId);
      notes.add(newNote);
      await _saveWebNotes(notes);
      return nextId;
    } else {
      final db = await database;
      return await db.insert(
        tableNotes,
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Lấy tất cả ghi chú sắp xếp theo updatedAt giảm dần (Get All Notes)
  Future<List<Note>> getAllNotes() async {
    if (kIsWeb) {
      final notes = await _getWebNotes();
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes;
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableNotes,
        orderBy: '$columnUpdatedAt DESC',
      );
      return maps.map((map) => Note.fromMap(map)).toList();
    }
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    if (kIsWeb) {
      final notes = await _getWebNotes();
      try {
        return notes.firstWhere((n) => n.id == id);
      } catch (_) {
        return null;
      }
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableNotes,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Note.fromMap(maps.first);
      }
      return null;
    }
  }

  // Cập nhật ghi chú (Update Note)
  Future<int> updateNote(Note note) async {
    if (note.id == null) return 0;

    if (kIsWeb) {
      final notes = await _getWebNotes();
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = note;
        await _saveWebNotes(notes);
        return 1;
      }
      return 0;
    } else {
      final db = await database;
      return await db.update(
        tableNotes,
        note.toMap(),
        where: '$columnId = ?',
        whereArgs: [note.id],
      );
    }
  }

  // Xóa ghi chú (Delete Note)
  Future<int> deleteNote(int id) async {
    if (kIsWeb) {
      final notes = await _getWebNotes();
      final initialCount = notes.length;
      notes.removeWhere((n) => n.id == id);
      if (notes.length != initialCount) {
        await _saveWebNotes(notes);
        return 1;
      }
      return 0;
    } else {
      final db = await database;
      return await db.delete(
        tableNotes,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    }
  }

  // Tìm kiếm ghi chú theo từ khóa trong Tiêu đề hoặc Nội dung
  Future<List<Note>> searchNotes(String query) async {
    if (kIsWeb) {
      final lower = query.toLowerCase();
      final notes = await _getWebNotes();
      final filtered = notes.where((n) {
        return n.title.toLowerCase().contains(lower) ||
            n.content.toLowerCase().contains(lower);
      }).toList();
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return filtered;
    } else {
      final db = await database;
      final sanitized = '%$query%';
      final List<Map<String, dynamic>> maps = await db.query(
        tableNotes,
        where: '$columnTitle LIKE ? OR $columnContent LIKE ?',
        whereArgs: [sanitized, sanitized],
        orderBy: '$columnUpdatedAt DESC',
      );
      return maps.map((map) => Note.fromMap(map)).toList();
    }
  }

  // Đóng database
  Future<void> close() async {
    if (!kIsWeb) {
      final db = await database;
      db.close();
    }
  }
}
