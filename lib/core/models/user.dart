class User {
  final String id;
  final String fullName;
  final String username;
  final String? avatarUrl;
  final String? careerId;
  final String? university;
  final int studyYear;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    this.careerId,
    this.university,
    this.studyYear = 1,
    this.bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      careerId: map['career_id'] as String?,
      university: map['university'] as String?,
      studyYear: map['study_year'] as int? ?? 1,
      bio: map['bio'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'career_id': careerId,
      'university': university,
      'study_year': studyYear,
      'bio': bio,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? careerId,
    String? university,
    int? studyYear,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      careerId: careerId ?? this.careerId,
      university: university ?? this.university,
      studyYear: studyYear ?? this.studyYear,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
