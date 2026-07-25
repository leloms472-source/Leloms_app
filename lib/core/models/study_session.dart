import '../enums/enums.dart';

class StudySession {
  final String id;
  final String userId;
  final SessionType sessionType;
  final int minutes;
  final String? subjectName;
  final DateTime completedAt;

  StudySession({
    required this.id,
    required this.userId,
    required this.sessionType,
    required this.minutes,
    this.subjectName,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      sessionType: SessionType.values.firstWhere(
        (e) => e.name == map['session_type'],
        orElse: () => SessionType.custom,
      ),
      minutes: map['minutes'] as int? ?? 0,
      subjectName: map['subject_name'] as String?,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'session_type': sessionType.name,
      'minutes': minutes,
      'subject_name': subjectName,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
