import '../core/repositories/content_repository.dart';
import '../models/subject.dart';
import '../models/quiz.dart';
import '../models/flashcard.dart';
import '../models/summary.dart';

class SupabaseService {
  final ContentRepository _repo = ContentRepository();

  Future<List<Subject>> getSubjects() async {
    final models = await _repo.getSubjects();
    return models.map((m) => Subject(
      id: m.id,
      name: m.name,
      progress: m.progress,
      resources: m.resources,
      completed: m.completed,
      color: m.color,
      icon: m.icon,
    )).toList();
  }

  Future<List<Quiz>> getQuizzes({String? subject}) async {
    final models = await _repo.getQuizzes(subject: subject);
    return models.map((m) => Quiz(
      id: m.id,
      title: m.title,
      subject: m.subject,
      difficulty: m.difficulty,
      timeMinutes: m.timeMinutes,
      questions: m.questions.map((q) => QuizQuestion(
        question: q.question,
        options: q.options,
        correctIndex: q.correctIndex,
        explanation: q.explanation,
      )).toList(),
    )).toList();
  }

  Future<List<Flashcard>> getFlashcards({String? subject}) async {
    final models = await _repo.getFlashcards(subject: subject);
    return models.map((m) => Flashcard(
      id: m.id,
      front: m.front,
      back: m.back,
      subject: m.subject,
      isLearned: m.isLearned,
      easinessFactor: m.easinessFactor,
      interval: m.interval,
      repetitions: m.repetitions,
      nextReviewDate: m.nextReviewDate,
    )).toList();
  }

  Future<List<Summary>> getSummaries() async {
    return [];
  }

  Future<void> voteSummary(String summaryId, int newVotes) async {
    // Placeholder
  }
}
