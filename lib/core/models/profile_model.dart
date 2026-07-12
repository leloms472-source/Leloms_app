class ProfileModel {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int streak;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.level = 1,
    this.currentXp = 0,
    this.nextLevelXp = 100,
    this.streak = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Estudiante',
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      level: (map['level'] as num?)?.toInt() ?? 1,
      currentXp: (map['current_xp'] as num?)?.toInt() ?? 0,
      nextLevelXp: (map['next_level_xp'] as num?)?.toInt() ?? 100,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'level': level,
        'current_xp': currentXp,
        'next_level_xp': nextLevelXp,
        'streak': streak,
      };

  double get xpProgress => nextLevelXp > 0 ? currentXp / nextLevelXp : 0;

  ProfileModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? level,
    int? currentXp,
    int? nextLevelXp,
    int? streak,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      streak: streak ?? this.streak,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
