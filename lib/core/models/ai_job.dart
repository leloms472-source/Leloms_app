import '../enums/enums.dart';

class AiJob {
  final String id;
  final String userId;
  final String resourceId;
  final AiJobStatus status;
  final String? resultUrl;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  AiJob({
    required this.id,
    required this.userId,
    required this.resourceId,
    this.status = AiJobStatus.pending,
    this.resultUrl,
    this.errorMessage,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AiJob.fromMap(Map<String, dynamic> map) {
    return AiJob(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      resourceId: map['resource_id'] as String? ?? '',
      status: AiJobStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AiJobStatus.pending,
      ),
      resultUrl: map['result_url'] as String?,
      errorMessage: map['error_message'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'resource_id': resourceId,
      'status': status.name,
      'result_url': resultUrl,
      'error_message': errorMessage,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
