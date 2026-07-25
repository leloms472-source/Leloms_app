class StudyPlan {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime examDate;
  final DateTime createdAt;
  final double progress;
  final int totalTopics;

  StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.examDate,
    DateTime? createdAt,
    this.progress = 0.0,
    this.totalTopics = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      examDate: map['exam_date'] != null ? DateTime.parse(map['exam_date'] as String) : DateTime.now(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      totalTopics: map['total_topics'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'exam_date': examDate.toIso8601String(),
      'progress': progress,
      'total_topics': totalTopics,
    };
  }
}
