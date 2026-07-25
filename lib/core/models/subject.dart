class Subject {
  final String id;
  final String name;
  final String? description;
  final String careerId;
  final int orderIndex;
  final String? color;
  final String? iconName;
  final int topicsCount;

  const Subject({
    required this.id,
    required this.name,
    this.description,
    required this.careerId,
    this.orderIndex = 0,
    this.color,
    this.iconName,
    this.topicsCount = 0,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      careerId: map['career_id'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
      color: map['color'] as String?,
      iconName: map['icon_name'] as String?,
      topicsCount: map['topics_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'description': description,
      'career_id': careerId,
      'order_index': orderIndex,
      'color': color,
      'icon_name': iconName,
      'topics_count': topicsCount,
    };
  }
}
