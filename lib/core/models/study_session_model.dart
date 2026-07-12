class StudySessionModel {
  final String id;
  final String userId;
  final String sessionType;
  final int minutes;
  final int xpEarned;
  final String? subject;
  final DateTime completedAt;

  StudySessionModel({
    required this.id,
    required this.userId,
    this.sessionType = 'pomodoro',
    this.minutes = 0,
    this.xpEarned = 0,
    this.subject,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  factory StudySessionModel.fromMap(Map<String, dynamic> map) {
    return StudySessionModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      sessionType: map['session_type'] as String? ?? 'pomodoro',
      minutes: (map['minutes'] as num?)?.toInt() ?? 0,
      xpEarned: (map['xp_earned'] as num?)?.toInt() ?? 0,
      subject: map['subject'] as String?,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'session_type': sessionType,
        'minutes': minutes,
        'xp_earned': xpEarned,
        'subject': subject,
      };
}
