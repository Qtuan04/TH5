import 'package:flutter/material.dart';

class EmptyNotesView extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onAddNote;

  const EmptyNotesView({
    super.key,
    required this.isSearching,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSearching
                    ? Colors.orange.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.edit_note_rounded,
                size: 72,
                color: isSearching
                    ? Colors.orange
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching
                  ? 'Không tìm thấy kết quả'
                  : 'Chưa có ghi chú nào',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isSearching
                  ? 'Thử tìm kiếm với từ khóa khác trong tiêu đề hoặc nội dung'
                  : 'Hãy ghi lại những ý tưởng, công việc hoặc lời nhắc của bạn ngay hôm nay',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onAddNote,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Tạo ghi chú mới',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
