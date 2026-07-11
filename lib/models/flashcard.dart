class Flashcard {
  final String id;
  final String front;
  final String back;
  final String subject;
  bool isLearned;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.subject = '',
    this.isLearned = false,
  });

  factory Flashcard.fromMap(String id, Map<String, dynamic> map) {
    return Flashcard(
      id: id,
      front: map['front'] as String? ?? '',
      back: map['back'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      isLearned: map['isLearned'] as bool? ?? false,
    );
  }
}
