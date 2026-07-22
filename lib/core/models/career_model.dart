import 'package:flutter/material.dart';

class Career {
  final String id;
  final String name;
  final String? description;
  final Color color;
  final String iconName;
  final int subjectCount;

  Career({
    required this.id,
    required this.name,
    this.description,
    this.color = const Color(0xFF6366F1),
    this.iconName = 'school',
    this.subjectCount = 0,
  });

  IconData get icon {
    switch (iconName) {
      case 'medication':
        return Icons.medication_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'biotech':
        return Icons.biotech_rounded;
      case 'health_and_safety':
        return Icons.health_and_safety_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'computer':
        return Icons.computer_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  factory Career.fromMap(String id, Map<String, dynamic> map) {
    return Career(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      color: Color(map['color'] as int? ?? 0xFF6366F1),
      iconName: map['icon_name'] as String? ?? 'school',
      subjectCount: (map['subject_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'color': color.toARGB32(),
        'icon_name': iconName,
        'subject_count': subjectCount,
      };
}
