class ExamConfig {
  final List<String> subjects;
  final int totalQuestions;
  final int timeMinutes;
  final bool randomizeOrder;
  final bool showResultsAfter;

  const ExamConfig({
    this.subjects = const [],
    this.totalQuestions = 20,
    this.timeMinutes = 30,
    this.randomizeOrder = true,
    this.showResultsAfter = true,
  });

  String get difficulty {
    final qPerMin = totalQuestions / timeMinutes;
    if (qPerMin > 1.5) return 'Difícil';
    if (qPerMin > 0.8) return 'Intermedio';
    return 'Relajado';
  }
}

class ExamResult {
  final int correctCount;
  final int totalQuestions;
  final int timeSpentSeconds;
  final Map<String, int> subjectCorrect;
  final Map<String, int> subjectTotal;
  final List<bool> answerResults;

  const ExamResult({
    required this.correctCount,
    required this.totalQuestions,
    required this.timeSpentSeconds,
    required this.subjectCorrect,
    required this.subjectTotal,
    required this.answerResults,
  });

  double get percentage => totalQuestions > 0 ? correctCount / totalQuestions : 0;
  int get score => (percentage * 100).round();
  double get averageTimePerQuestion => totalQuestions > 0 ? timeSpentSeconds / totalQuestions : 0;

  Map<String, double> get subjectPercentages {
    return subjectTotal.map((subject, total) {
      final correct = subjectCorrect[subject] ?? 0;
      return MapEntry(subject, total > 0 ? correct / total : 0);
    });
  }
}

class ExamQuestionResult {
  final String question;
  final String subject;
  final int selectedAnswer;
  final int correctAnswer;
  final int timeSpent;
  final bool isCorrect;

  const ExamQuestionResult({
    required this.question,
    required this.subject,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.timeSpent,
    required this.isCorrect,
  });
}
