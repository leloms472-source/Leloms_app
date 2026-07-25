class Favorite {
  final String id;
  final String userId;
  final String resourceId;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.resourceId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      resourceId: map['resource_id'] as String? ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'resource_id': resourceId,
    };
  }
}
