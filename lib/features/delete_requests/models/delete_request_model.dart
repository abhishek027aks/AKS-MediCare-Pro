class DeleteRequestModel {
  const DeleteRequestModel({
    this.id,
    required this.module,
    required this.recordId,
    required this.recordLabel,
    required this.reason,
    required this.status,
    required this.requestedByUserId,
    required this.requestedByName,
    this.reviewedByUserId,
    this.reviewedByName,
    this.reviewedAt,
    required this.requestedAt,
  });

  final int? id;
  final String module;
  final int recordId;
  final String recordLabel;
  final String reason;
  final String status;
  final int requestedByUserId;
  final String requestedByName;
  final int? reviewedByUserId;
  final String? reviewedByName;
  final DateTime? reviewedAt;
  final DateTime requestedAt;

  DeleteRequestModel copyWith({
    int? id,
    String? module,
    int? recordId,
    String? recordLabel,
    String? reason,
    String? status,
    int? requestedByUserId,
    String? requestedByName,
    int? reviewedByUserId,
    String? reviewedByName,
    DateTime? reviewedAt,
    DateTime? requestedAt,
  }) {
    return DeleteRequestModel(
      id: id ?? this.id,
      module: module ?? this.module,
      recordId: recordId ?? this.recordId,
      recordLabel: recordLabel ?? this.recordLabel,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      requestedByName: requestedByName ?? this.requestedByName,
      reviewedByUserId: reviewedByUserId ?? this.reviewedByUserId,
      reviewedByName: reviewedByName ?? this.reviewedByName,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module': module,
      'record_id': recordId,
      'record_label': recordLabel,
      'reason': reason,
      'status': status,
      'requested_by_user_id': requestedByUserId,
      'requested_by_name': requestedByName,
      'reviewed_by_user_id': reviewedByUserId,
      'reviewed_by_name': reviewedByName,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'requested_at': requestedAt.toIso8601String(),
    };
  }

  factory DeleteRequestModel.fromMap(Map<String, dynamic> map) {
    return DeleteRequestModel(
      id: map['id'] as int?,
      module: map['module'] as String,
      recordId: map['record_id'] as int,
      recordLabel: map['record_label'] as String,
      reason: map['reason'] as String,
      status: map['status'] as String,
      requestedByUserId: map['requested_by_user_id'] as int,
      requestedByName: map['requested_by_name'] as String,
      reviewedByUserId: map['reviewed_by_user_id'] as int?,
      reviewedByName: map['reviewed_by_name'] as String?,
      reviewedAt: map['reviewed_at'] == null ? null : DateTime.parse(map['reviewed_at'] as String),
      requestedAt: DateTime.parse(map['requested_at'] as String),
    );
  }

  @override
  String toString() {
    return 'DeleteRequestModel(module: $module, recordLabel: $recordLabel, status: $status)';
  }
}
