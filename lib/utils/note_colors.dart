import 'package:flutter/material.dart';

class NoteColorItem {
  final String name;
  final Color lightColor;
  final Color darkColor;
  final Color borderColor;

  const NoteColorItem({
    required this.name,
    required this.lightColor,
    required this.darkColor,
    required this.borderColor,
  });
}

class NoteColors {
  static const List<NoteColorItem> palettes = [
    NoteColorItem(
      name: 'Mặc định',
      lightColor: Color(0xFFFFFFFF),
      darkColor: Color(0xFF1E1E2E),
      borderColor: Color(0xFFE0E0E0),
    ),
    NoteColorItem(
      name: 'Xanh bạc hà',
      lightColor: Color(0xFFE8F5E9),
      darkColor: Color(0xFF1B382B),
      borderColor: Color(0xFFA5D6A7),
    ),
    NoteColorItem(
      name: 'Xanh dương nhạt',
      lightColor: Color(0xFFE3F2FD),
      darkColor: Color(0xFF1B2F3E),
      borderColor: Color(0xFF90CAF9),
    ),
    NoteColorItem(
      name: 'Vàng kem',
      lightColor: Color(0xFFFFF9C4),
      darkColor: Color(0xFF3E3A1E),
      borderColor: Color(0xFFFFF176),
    ),
    NoteColorItem(
      name: 'Hồng cam pastel',
      lightColor: Color(0xFFFFE0B2),
      darkColor: Color(0xFF3E2D1E),
      borderColor: Color(0xFFFFB74D),
    ),
    NoteColorItem(
      name: 'Tím oải hương',
      lightColor: Color(0xFFF3E5F5),
      darkColor: Color(0xFF35203D),
      borderColor: Color(0xFFCE93D8),
    ),
    NoteColorItem(
      name: 'Hồng phấn',
      lightColor: Color(0xFFFFEBEE),
      darkColor: Color(0xFF3E1E25),
      borderColor: Color(0xFFEF9A9A),
    ),
  ];

  static NoteColorItem getColor(int index) {
    if (index < 0 || index >= palettes.length) {
      return palettes[0];
    }
    return palettes[index];
  }
}
