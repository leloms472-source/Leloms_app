class Resource {
  final String id;
  final String authorId;
  final String? topicId;
  final String title;
  final String? description;
  final String? pdfUrl;
  final bool isPublic;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.authorId,
    this.topicId,
    required this.title,
    this.description,
    this.pdfUrl,
    this.isPublic = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] as String,
      authorId: map['author_id'] as String? ?? '',
      topicId: map['topic_id'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      pdfUrl: map['pdf_url'] as String?,
      isPublic: map['is_public'] as bool? ?? false,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'author_id': authorId,
      'topic_id': topicId,
      'title': title,
      'description': description,
      'pdf_url': pdfUrl,
      'is_public': isPublic,
    };
  }

  Resource copyWith({bool? isPublic}) {
    return Resource(
      id: id,
      authorId: authorId,
      topicId: topicId,
      title: title,
      description: description,
      pdfUrl: pdfUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt,
    );
  }
}
