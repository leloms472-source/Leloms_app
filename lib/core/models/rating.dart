class Rating {
  final String id;
  final String userId;
  final String resourceId;
  final int value;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.userId,
    required this.resourceId,
    required this.value,
    DateTime? createdAt,
  })  : assert(value >= 1 && value <= 5),
        createdAt = createdAt ?? DateTime.now();

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      resourceId: map['resource_id'] as String? ?? '',
      value: map['value'] as int? ?? 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'resource_id': resourceId,
      'value': value,
    };
  }
}
