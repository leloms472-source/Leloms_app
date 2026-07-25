import '../enums/enums.dart';

class HelpRequest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String? subjectName;
  final HelpRequestStatus status;
  final String? helperId;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  HelpRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.subjectName,
    this.status = HelpRequestStatus.open,
    this.helperId,
    DateTime? createdAt,
    this.resolvedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HelpRequest.fromMap(Map<String, dynamic> map) {
    return HelpRequest(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      subjectName: map['subject_name'] as String?,
      status: HelpRequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => HelpRequestStatus.open,
      ),
      helperId: map['helper_id'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      resolvedAt: map['resolved_at'] != null ? DateTime.parse(map['resolved_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'subject_name': subjectName,
      'status': status.name,
      'helper_id': helperId,
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}
