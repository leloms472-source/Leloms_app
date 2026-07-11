class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] as String? ?? '',
      options: (map['options'] as List<dynamic>?)?.cast<String>() ?? [],
      correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: map['explanation'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final String difficulty;
  final List<QuizQuestion> questions;
  final int timeMinutes;

  const Quiz({
    required this.id,
    required this.title,
    required this.subject,
    this.difficulty = 'Intermedio',
    required this.questions,
    this.timeMinutes = 10,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      id: id,
      title: map['title'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? 'Intermedio',
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      timeMinutes: (map['timeMinutes'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'subject': subject,
        'difficulty': difficulty,
        'questions': questions.map((q) => q.toMap()).toList(),
        'timeMinutes': timeMinutes,
      };
}
