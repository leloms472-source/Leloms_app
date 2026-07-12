enum ChallengeType { studyTime, flashcards, quizQuestions, streak, pomodoroSessions }

class DailyChallengeModel {
  final ChallengeType type;
  final int target;
  final String title;
  final String description;
  final int xpReward;
  int progress;

  DailyChallengeModel({
    required this.type,
    required this.target,
    required this.title,
    required this.description,
    required this.xpReward,
    this.progress = 0,
  });

  bool get isCompleted => progress >= target;
  double get progressFraction => (progress / target).clamp(0.0, 1.0);
}
