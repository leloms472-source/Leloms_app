import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final double progress;
  final int resources;
  final int completed;
  final Color color;
  final IconData icon;

  const Subject({
    required this.id,
    required this.name,
    this.progress = 0.0,
    this.resources = 0,
    this.completed = 0,
    this.color = const Color(0xFF6366F1),
    this.icon = Icons.school_rounded,
  });

  factory Subject.fromMap(String id, Map<String, dynamic> map) {
    return Subject(
      id: id,
      name: map['name'] as String? ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      resources: (map['resources'] as num?)?.toInt() ?? 0,
      completed: (map['completed'] as num?)?.toInt() ?? 0,
      color: Color(map['color'] as int? ?? 0xFF6366F1),
      icon: Icons.school_rounded,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'progress': progress,
        'resources': resources,
        'completed': completed,
        'color': color.toARGB32(),
      };
}
