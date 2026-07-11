class Summary {
  final String id;
  final String title;
  final String author;
  final String subject;
  final String difficulty;
  int votes;
  int comments;
  bool isVoted;

  Summary({
    required this.id,
    required this.title,
    required this.author,
    required this.subject,
    this.difficulty = 'Intermedio',
    this.votes = 0,
    this.comments = 0,
    this.isVoted = false,
  });

  factory Summary.fromMap(String id, Map<String, dynamic> map) {
    return Summary(
      id: id,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? 'Intermedio',
      votes: (map['votes'] as num?)?.toInt() ?? 0,
      comments: (map['comments'] as num?)?.toInt() ?? 0,
    );
  }
}
