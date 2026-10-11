import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/database_helper.dart';
import '../utils/note_colors.dart';
import '../widgets/confirm_delete_dialog.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late int _selectedColorIndex;
  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColorIndex = widget.note?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ít nhất tiêu đề hoặc nội dung!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();

      if (_isEditing) {
        final updatedNote = widget.note!.copyWith(
          title: title.isEmpty ? 'Không có tiêu đề' : title,
          content: content,
          updatedAt: now,
          colorIndex: _selectedColorIndex,
        );
        await DatabaseHelper.instance.updateNote(updatedNote);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật ghi chú thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final newNote = Note(
          title: title.isEmpty ? 'Không có tiêu đề' : title,
          content: content,
          createdAt: now,
          updatedAt: now,
          colorIndex: _selectedColorIndex,
        );
        await DatabaseHelper.instance.insertNote(newNote);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã lưu ghi chú mới thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // Trả về true để màn hình chính cập nhật danh sách
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu ghi chú: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteNote() async {
    if (!_isEditing) return;

    final shouldDelete = await showConfirmDeleteDialog(
      context,
      noteTitle: widget.note!.title,
    );

    if (shouldDelete) {
      await DatabaseHelper.instance.deleteNote(widget.note!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa ghi chú!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorItem = NoteColors.getColor(_selectedColorIndex);
    final editorBgColor = isDark ? colorItem.darkColor : colorItem.lightColor;

    return Scaffold(
      backgroundColor: editorBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Nút Xóa (chỉ hiển thị khi đang sửa)
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              tooltip: 'Xóa ghi chú',
              onPressed: _deleteNote,
            ),
          // Nút Lưu
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveNote,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 20),
              label: const Text('Lưu'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh chọn màu sắc bảng màu pastel
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: NoteColors.palettes.length,
                itemBuilder: (context, index) {
                  final item = NoteColors.palettes[index];
                  final isSelected = _selectedColorIndex == index;
                  final circleColor = isDark ? item.darkColor : item.lightColor;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : item.borderColor,
                          width: isSelected ? 2.5 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: isDark ? Colors.white : Colors.black87,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // Form nhập liệu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Trường nhập Tiêu đề
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tiêu đề ghi chú...',
                      hintStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  // Trường nhập Nội dung chi tiết
                  TextField(
                    controller: _contentController,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? Colors.grey.shade200 : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung ghi chú tại đây...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
