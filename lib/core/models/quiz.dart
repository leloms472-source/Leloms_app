class QuizQuestion {
  final String id;
  final String quizId;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      quizId: map['quiz_id'] as String? ?? '',
      question: map['question'] as String? ?? '',
      options: (map['options'] as List<dynamic>?)?.cast<String>() ?? [],
      correctAnswer: map['correct_answer'] as int? ?? 0,
      explanation: map['explanation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'quiz_id': quizId,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class QuizResult {
  final int totalQuestions;
  final int correctCount;
  final double percentage;
  final int score;
  final int timeSpentSeconds;
  final Map<String, int> subjectBreakdown;

  QuizResult({
    required this.totalQuestions,
    required this.correctCount,
    required this.percentage,
    required this.score,
    this.timeSpentSeconds = 0,
    this.subjectBreakdown = const {},
  });

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      totalQuestions: map['total_questions'] as int? ?? 0,
      correctCount: map['correct_count'] as int? ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      score: map['score'] as int? ?? 0,
      timeSpentSeconds: map['time_spent_seconds'] as int? ?? 0,
      subjectBreakdown: (map['subject_breakdown'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_questions': totalQuestions,
      'correct_count': correctCount,
      'percentage': percentage,
      'score': score,
      'time_spent_seconds': timeSpentSeconds,
      'subject_breakdown': subjectBreakdown,
    };
  }
}
