class StudyPlan {
  final String id;
  final String examTitle;
  final DateTime examDate;
  final DateTime startDate;
  final List<String> subjects;
  final int hoursPerDay;
  final List<StudyDay> days;
  final DateTime createdAt;

  const StudyPlan({
    required this.id,
    required this.examTitle,
    required this.examDate,
    required this.startDate,
    required this.subjects,
    required this.hoursPerDay,
    required this.days,
    required this.createdAt,
  });

  int get totalDays => days.length;
  int get completedDays => days.where((d) => d.isComplete).length;
  double get progress => totalDays > 0 ? completedDays / totalDays : 0;

  Map<String, dynamic> toMap() {
    return {
      'examTitle': examTitle,
      'examDate': examDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'subjects': subjects,
      'hoursPerDay': hoursPerDay,
      'days': days.map((d) => d.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyPlan.fromMap(String id, Map<String, dynamic> map) {
    return StudyPlan(
      id: id,
      examTitle: map['examTitle'] as String? ?? '',
      examDate: DateTime.parse(map['examDate'] as String),
      startDate: DateTime.parse(map['startDate'] as String),
      subjects: (map['subjects'] as List<dynamic>?)?.cast<String>() ?? [],
      hoursPerDay: (map['hoursPerDay'] as num?)?.toInt() ?? 2,
      days: (map['days'] as List<dynamic>?)
              ?.map((d) => StudyDay.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class StudyDay {
  final DateTime date;
  final List<StudyTopic> topics;
  bool isComplete;

  StudyDay({
    required this.date,
    required this.topics,
    this.isComplete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'topics': topics.map((t) => t.toMap()).toList(),
      'isComplete': isComplete,
    };
  }

  factory StudyDay.fromMap(Map<String, dynamic> map) {
    return StudyDay(
      date: DateTime.parse(map['date'] as String),
      topics: (map['topics'] as List<dynamic>?)
              ?.map((t) => StudyTopic.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      isComplete: map['isComplete'] as bool? ?? false,
    );
  }
}

class StudyTopic {
  final String subject;
  final String topic;
  final int hours;
  bool isDone;

  StudyTopic({
    required this.subject,
    required this.topic,
    this.hours = 1,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'topic': topic,
      'hours': hours,
      'isDone': isDone,
    };
  }

  factory StudyTopic.fromMap(Map<String, dynamic> map) {
    return StudyTopic(
      subject: map['subject'] as String? ?? '',
      topic: map['topic'] as String? ?? '',
      hours: (map['hours'] as num?)?.toInt() ?? 1,
      isDone: map['isDone'] as bool? ?? false,
    );
  }
}

class StudyPlanGenerator {
  static StudyPlan generate({
    required String examTitle,
    required DateTime examDate,
    required List<String> subjects,
    int hoursPerDay = 2,
  }) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final totalDays = examDate.difference(startDate).inDays;

    if (totalDays <= 0) {
      return StudyPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        examTitle: examTitle,
        examDate: examDate,
        startDate: startDate,
        subjects: subjects,
        hoursPerDay: hoursPerDay,
        days: [],
        createdAt: now,
      );
    }

    final topicPool = <String>[];
    for (final subject in subjects) {
      for (int i = 1; i <= 5; i++) {
        topicPool.add('$subject - Tema $i');
      }
    }
    topicPool.shuffle();

    final days = <StudyDay>[];
    final topicsPerDay = (topicPool.length / totalDays).ceil().clamp(1, 4);
    int topicIndex = 0;

    for (int d = 0; d < totalDays; d++) {
      final date = startDate.add(Duration(days: d));
      final dayTopics = <StudyTopic>[];

      final daySubjectIndex = d % subjects.length;
      final subject = subjects[daySubjectIndex];

      for (int t = 0; t < topicsPerDay && topicIndex < topicPool.length; t++) {
        dayTopics.add(StudyTopic(
          subject: subject,
          topic: topicPool[topicIndex],
          hours: 1,
        ));
        topicIndex++;
      }

      if (topicIndex >= topicPool.length) {
        topicIndex = 0;
        for (final s in subjects) {
          for (int i = 1; i <= 5; i++) {
            topicPool.add('$s - Tema ${i + 5}');
          }
        }
        topicPool.shuffle();
      }

      days.add(StudyDay(date: date, topics: dayTopics));
    }

    return StudyPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      examTitle: examTitle,
      examDate: examDate,
      startDate: startDate,
      subjects: subjects,
      hoursPerDay: hoursPerDay,
      days: days,
      createdAt: now,
    );
  }
}
