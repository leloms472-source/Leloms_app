class Comment {
  final String id;
  final String authorId;
  final String resourceId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.authorId,
    required this.resourceId,
    required this.content,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      authorId: map['author_id'] as String? ?? '',
      resourceId: map['resource_id'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'author_id': authorId,
      'resource_id': resourceId,
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
