import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/note_colors.dart';
import 'confirm_delete_dialog.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  void _showLongPressOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      note.title.isNotEmpty ? note.title : 'Ghi chú không có tiêu đề',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                  title: const Text('Chỉnh sửa ghi chú'),
                  onTap: () {
                    Navigator.pop(ctx);
                    onEdit();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Xóa ghi chú', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final shouldDelete = await showConfirmDeleteDialog(
                      context,
                      noteTitle: note.title,
                    );
                    if (shouldDelete) {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorItem = NoteColors.getColor(note.colorIndex);
    final cardBgColor = isDark ? colorItem.darkColor : colorItem.lightColor;
    final borderColor = isDark
        ? colorItem.borderColor.withValues(alpha: 0.3)
        : colorItem.borderColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Dismissible(
        key: ValueKey('note_${note.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          // Bật dialog xác nhận trước khi xóa theo yêu cầu đề bài
          return await showConfirmDeleteDialog(
            context,
            noteTitle: note.title,
          );
        },
        onDismissed: (direction) {
          onDelete();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Xóa',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        child: Material(
          color: cardBgColor,
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showLongPressOptions(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề ghi chú
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isNotEmpty ? note.title : '(Không có tiêu đề)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Icon nút xóa nhanh tiện lợi
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Xóa ghi chú',
                        onPressed: () async {
                          final shouldDelete = await showConfirmDeleteDialog(
                            context,
                            noteTitle: note.title,
                          );
                          if (shouldDelete) {
                            onDelete();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Nội dung ngắn tóm tắt (snippet)
                  Text(
                    note.snippet,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Thời gian tạo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            note.formattedCreatedAt,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Tag hiển thị trạng thái sửa
                      if (note.updatedAt.isAfter(note.createdAt.add(const Duration(minutes: 1))))
                        Text(
                          'Đã sửa',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
