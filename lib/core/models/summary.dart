class Summary {
  final String id;
  final String resourceId;
  final String shortSummary;
  final String fullSummary;
  final List<String> keywords;
  final List<String> keyConcepts;
  final DateTime createdAt;

  Summary({
    required this.id,
    required this.resourceId,
    required this.shortSummary,
    required this.fullSummary,
    this.keywords = const [],
    this.keyConcepts = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      id: map['id'] as String,
      resourceId: map['resource_id'] as String? ?? '',
      shortSummary: map['short_summary'] as String? ?? '',
      fullSummary: map['full_summary'] as String? ?? '',
      keywords: (map['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      keyConcepts: (map['key_concepts'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'resource_id': resourceId,
      'short_summary': shortSummary,
      'full_summary': fullSummary,
      'keywords': keywords,
      'key_concepts': keyConcepts,
    };
  }
}
