/// Tracks the real-time SSE streaming state of a cluster-article generation job.
enum ClusterJobStatus { pending, running, completed, failed }

class ClusterJob {
  final String jobId;
  final ClusterJobStatus status;

  /// 0–100 progress percentage
  final int progress;

  /// Human-readable status message from the stream
  final String message;

  /// List of article IDs that have been generated so far
  final List<String> completedArticles;

  ClusterJob({
    required this.jobId,
    required this.status,
    required this.progress,
    required this.message,
    this.completedArticles = const [],
  });

  factory ClusterJob.initial(String jobId) => ClusterJob(
        jobId: jobId,
        status: ClusterJobStatus.pending,
        progress: 0,
        message: 'Job queued…',
      );

  ClusterJob copyWith({
    ClusterJobStatus? status,
    int? progress,
    String? message,
    List<String>? completedArticles,
  }) {
    return ClusterJob(
      jobId: jobId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      completedArticles: completedArticles ?? this.completedArticles,
    );
  }

  /// Parse an SSE data event payload from the backend stream.
  /// Expected JSON shape: { "status": "running", "progress": 42, "message": "...", "completedArticles": [...] }
  factory ClusterJob.fromSseEvent(String jobId, Map<String, dynamic> map) {
    final statusStr = (map['status'] ?? 'pending').toString();
    final status = ClusterJobStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => ClusterJobStatus.running,
    );
    return ClusterJob(
      jobId: jobId,
      status: status,
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      message: (map['message'] ?? '').toString(),
      completedArticles: (map['completedArticles'] ?? map['completed_articles'] ?? [])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toList(),
    );
  }
}
