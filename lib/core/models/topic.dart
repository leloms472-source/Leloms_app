class Topic {
  final String id;
  final String name;
  final String? description;
  final String subjectId;
  final int orderIndex;
  final String? color;

  const Topic({
    required this.id,
    required this.name,
    this.description,
    required this.subjectId,
    this.orderIndex = 0,
    this.color,
  });

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      subjectId: map['subject_id'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
      color: map['color'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'description': description,
      'subject_id': subjectId,
      'order_index': orderIndex,
      'color': color,
    };
  }
}
