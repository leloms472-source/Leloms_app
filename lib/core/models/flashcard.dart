class Flashcard {
  final String id;
  final String resourceId;
  final String question;
  final String answer;
  final bool isLearned;
  final double easinessFactor;
  final int interval;
  final int repetitions;
  final DateTime? nextReviewDate;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.resourceId,
    required this.question,
    required this.answer,
    this.isLearned = false,
    this.easinessFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReviewDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      resourceId: map['resource_id'] as String? ?? '',
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
      isLearned: map['is_learned'] as bool? ?? false,
      easinessFactor: (map['easiness_factor'] as num?)?.toDouble() ?? 2.5,
      interval: map['interval'] as int? ?? 0,
      repetitions: map['repetitions'] as int? ?? 0,
      nextReviewDate: map['next_review_date'] != null ? DateTime.parse(map['next_review_date'] as String) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'resource_id': resourceId,
      'question': question,
      'answer': answer,
      'is_learned': isLearned,
      'easiness_factor': easinessFactor,
      'interval': interval,
      'repetitions': repetitions,
      'next_review_date': nextReviewDate?.toIso8601String(),
    };
  }

  Flashcard copyWith({bool? isLearned, double? easinessFactor, int? interval, int? repetitions, DateTime? nextReviewDate}) {
    return Flashcard(
      id: id,
      resourceId: resourceId,
      question: question,
      answer: answer,
      isLearned: isLearned ?? this.isLearned,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      createdAt: createdAt,
    );
  }
}
