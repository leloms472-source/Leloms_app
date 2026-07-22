import 'package:flutter/material.dart';

class Topic {
  final String id;
  final String name;
  final String? description;
  final String subjectId;
  final int orderIndex;
  final Color color;
  final int resourcesCount;
  final double progress;

  Topic({
    required this.id,
    required this.name,
    this.description,
    required this.subjectId,
    this.orderIndex = 0,
    this.color = const Color(0xFF6366F1),
    this.resourcesCount = 0,
    this.progress = 0.0,
  });

  factory Topic.fromMap(String id, Map<String, dynamic> map) {
    return Topic(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      subjectId: map['subject_id'] as String? ?? '',
      orderIndex: (map['order_index'] as num?)?.toInt() ?? 0,
      color: Color(map['color'] as int? ?? 0xFF6366F1),
      resourcesCount: (map['resources_count'] as num?)?.toInt() ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'subject_id': subjectId,
        'order_index': orderIndex,
        'color': color.toARGB32(),
        'resources_count': resourcesCount,
        'progress': progress,
      };
}
