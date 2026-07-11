class Flashcard {
  final String id;
  final String front;
  final String back;
  final String subject;
  bool isLearned;
  double easinessFactor;
  int interval;
  int repetitions;
  DateTime? nextReviewDate;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.subject = '',
    this.isLearned = false,
    this.easinessFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReviewDate,
  });

  bool get isDueForReview {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  int get daysUntilReview {
    if (nextReviewDate == null) return 0;
    return DateTime.now().difference(nextReviewDate!).inDays.abs();
  }

  Map<String, dynamic> toMap() {
    return {
      'front': front,
      'back': back,
      'subject': subject,
      'isLearned': isLearned,
      'easinessFactor': easinessFactor,
      'interval': interval,
      'repetitions': repetitions,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
    };
  }

  factory Flashcard.fromMap(String id, Map<String, dynamic> map) {
    return Flashcard(
      id: id,
      front: map['front'] as String? ?? '',
      back: map['back'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      isLearned: map['isLearned'] as bool? ?? false,
      easinessFactor: (map['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      interval: (map['interval'] as num?)?.toInt() ?? 0,
      repetitions: (map['repetitions'] as num?)?.toInt() ?? 0,
      nextReviewDate: map['nextReviewDate'] != null
          ? DateTime.parse(map['nextReviewDate'] as String)
          : null,
    );
  }
}

class Sm2Algorithm {
  static void applyReview(Flashcard card, int quality) {
    if (quality < 0 || quality > 5) return;

    if (quality >= 3) {
      card.repetitions++;
      switch (card.repetitions) {
        case 1:
          card.interval = 1;
        case 2:
          card.interval = 6;
        default:
          card.interval = (card.interval * card.easinessFactor).round();
      }
    } else {
      card.repetitions = 0;
      card.interval = 1;
    }

    card.easinessFactor += 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
    if (card.easinessFactor < 1.3) card.easinessFactor = 1.3;

    card.nextReviewDate = DateTime.now().add(Duration(days: card.interval));
    card.isLearned = true;
  }
}
