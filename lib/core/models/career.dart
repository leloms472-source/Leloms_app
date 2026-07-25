class Career {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? iconName;
  final int subjectCount;

  const Career({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.iconName,
    this.subjectCount = 0,
  });

  factory Career.fromMap(Map<String, dynamic> map) {
    return Career(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      color: map['color'] as String?,
      iconName: map['icon_name'] as String?,
      subjectCount: map['subject_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon_name': iconName,
      'subject_count': subjectCount,
    };
  }
}
