class ProfileModel {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? career;
  final String? university;
  final int semester;
  final int xp;
  final int level;
  final int streak;
  final bool premium;
  final int dailyStudyMinutes;
  final DateTime? lastLogin;
  final DateTime? lastStudyDate;
  final String? country;
  final String language;
  final String? timezone;
  final int? birthYear;
  final int? academicYear;
  final String? favoriteSubject;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.career,
    this.university,
    this.semester = 1,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.premium = false,
    this.dailyStudyMinutes = 0,
    this.lastLogin,
    this.lastStudyDate,
    this.country,
    this.language = 'es',
    this.timezone,
    this.birthYear,
    this.academicYear,
    this.favoriteSubject,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get nextLevelXp => 100 + (level - 1) * 50;

  double get xpProgress => nextLevelXp > 0 ? xp / nextLevelXp : 0;

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String? ?? '',
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      career: map['career'] as String?,
      university: map['university'] as String?,
      semester: (map['semester'] as num?)?.toInt() ?? 1,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      premium: map['premium'] as bool? ?? false,
      dailyStudyMinutes: (map['daily_study_minutes'] as num?)?.toInt() ?? 0,
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
      lastStudyDate: map['last_study_date'] != null
          ? DateTime.parse(map['last_study_date'] as String)
          : null,
      country: map['country'] as String?,
      language: map['language'] as String? ?? 'es',
      timezone: map['timezone'] as String?,
      birthYear: (map['birth_year'] as num?)?.toInt(),
      academicYear: (map['academic_year'] as num?)?.toInt(),
      favoriteSubject: map['favorite_subject'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        if (username != null) 'username': username,
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (career != null) 'career': career,
        if (university != null) 'university': university,
        'semester': semester,
        'xp': xp,
        'level': level,
        'streak': streak,
        'premium': premium,
        'daily_study_minutes': dailyStudyMinutes,
        if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
        if (lastStudyDate != null)
          'last_study_date': lastStudyDate!.toIso8601String().substring(0, 10),
        if (country != null) 'country': country,
        'language': language,
        if (timezone != null) 'timezone': timezone,
        if (birthYear != null) 'birth_year': birthYear,
        if (academicYear != null) 'academic_year': academicYear,
        if (favoriteSubject != null) 'favorite_subject': favoriteSubject,
      };

  Map<String, dynamic> toUpdateMap() => {
        if (username != null) 'username': username,
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (career != null) 'career': career,
        if (university != null) 'university': university,
        'semester': semester,
        'xp': xp,
        'level': level,
        'streak': streak,
        'premium': premium,
        'daily_study_minutes': dailyStudyMinutes,
        if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
        if (lastStudyDate != null)
          'last_study_date': lastStudyDate!.toIso8601String().substring(0, 10),
        if (country != null) 'country': country,
        'language': language,
        if (timezone != null) 'timezone': timezone,
        if (birthYear != null) 'birth_year': birthYear,
        if (academicYear != null) 'academic_year': academicYear,
        if (favoriteSubject != null) 'favorite_subject': favoriteSubject,
      };

  ProfileModel copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? career,
    String? university,
    int? semester,
    int? xp,
    int? level,
    int? streak,
    bool? premium,
    int? dailyStudyMinutes,
    DateTime? lastLogin,
    DateTime? lastStudyDate,
    String? country,
    String? language,
    String? timezone,
    int? birthYear,
    int? academicYear,
    String? favoriteSubject,
  }) {
    return ProfileModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      career: career ?? this.career,
      university: university ?? this.university,
      semester: semester ?? this.semester,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      premium: premium ?? this.premium,
      dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
      lastLogin: lastLogin ?? this.lastLogin,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      country: country ?? this.country,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      birthYear: birthYear ?? this.birthYear,
      academicYear: academicYear ?? this.academicYear,
      favoriteSubject: favoriteSubject ?? this.favoriteSubject,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
