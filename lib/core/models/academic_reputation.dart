class AcademicReputation {
  final String userId;
  final int usefulResources;
  final int studentsHelped;
  final int positiveRatings;
  final int acceptedContributions;
  final double overallScore;

  const AcademicReputation({
    required this.userId,
    this.usefulResources = 0,
    this.studentsHelped = 0,
    this.positiveRatings = 0,
    this.acceptedContributions = 0,
    this.overallScore = 0.0,
  });

  factory AcademicReputation.fromMap(Map<String, dynamic> map) {
    return AcademicReputation(
      userId: map['user_id'] as String? ?? '',
      usefulResources: map['useful_resources'] as int? ?? 0,
      studentsHelped: map['students_helped'] as int? ?? 0,
      positiveRatings: map['positive_ratings'] as int? ?? 0,
      acceptedContributions: map['accepted_contributions'] as int? ?? 0,
      overallScore: (map['overall_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'useful_resources': usefulResources,
      'students_helped': studentsHelped,
      'positive_ratings': positiveRatings,
      'accepted_contributions': acceptedContributions,
      'overall_score': overallScore,
    };
  }

  double get calculatedScore {
    final total = usefulResources + studentsHelped + positiveRatings + acceptedContributions;
    if (total == 0) return 0.0;
    return (usefulResources * 0.3 +
            studentsHelped * 0.3 +
            positiveRatings * 0.25 +
            acceptedContributions * 0.15)
        .toDouble();
  }
}
