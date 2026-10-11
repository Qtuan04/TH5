// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/models/note.dart';

void main() {
  test('Note model toMap and fromMap should preserve properties', () {
    final now = DateTime.now();
    final note = Note(
      id: 1,
      title: 'Học Flutter',
      content: 'Làm bài tập lớn ghi chú với SQLite',
      createdAt: now,
      updatedAt: now,
      colorIndex: 2,
    );

    final map = note.toMap();
    final reconstructed = Note.fromMap(map);

    expect(reconstructed.id, 1);
    expect(reconstructed.title, 'Học Flutter');
    expect(reconstructed.content, 'Làm bài tập lớn ghi chú với SQLite');
    expect(reconstructed.colorIndex, 2);
  });
}
