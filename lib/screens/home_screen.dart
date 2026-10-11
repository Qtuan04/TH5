import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/database_helper.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_notes_view.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Tải danh sách ghi chú từ SQLite
  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Note> notes;
      if (_searchQuery.trim().isEmpty) {
        notes = await DatabaseHelper.instance.getAllNotes();
      } else {
        notes = await DatabaseHelper.instance.searchNotes(_searchQuery.trim());
      }

      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  // Điều hướng đến màn hình Thêm mới
  Future<void> _navigateToAddNote() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteEditorScreen(),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  // Điều hướng đến màn hình Chỉnh sửa
  Future<void> _navigateToEditNote(Note note) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  // Xóa ghi chú khỏi SQLite
  Future<void> _deleteNote(Note note) async {
    if (note.id == null) return;

    try {
      await DatabaseHelper.instance.deleteNote(note.id!);
      _loadNotes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa ghi chú "${note.title}"'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Hoàn tác',
              textColor: Colors.amberAccent,
              onPressed: () async {
                await DatabaseHelper.instance.insertNote(note);
                _loadNotes();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tiêu đề hoặc nội dung...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _loadNotes();
                },
              )
            : Row(
                children: [
                  const Text(
                    'Ghi chú của tôi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  if (!_isLoading && _notes.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_notes.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm ghi chú',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                  _loadNotes();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? EmptyNotesView(
                  isSearching: _isSearching && _searchQuery.isNotEmpty,
                  onAddNote: _navigateToAddNote,
                )
              : RefreshIndicator(
                  onRefresh: _loadNotes,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => _navigateToEditNote(note),
                        onEdit: () => _navigateToEditNote(note),
                        onDelete: () => _deleteNote(note),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNote,
        icon: const Icon(Icons.add_rounded, size: 26),
        label: const Text(
          'Thêm ghi chú',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}
