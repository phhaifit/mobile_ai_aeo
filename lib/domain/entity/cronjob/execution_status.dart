enum ExecutionStatus {
  success,
  partial,
  failed,
}

extension ExecutionStatusExtension on ExecutionStatus {
  String get displayName {
    switch (this) {
      case ExecutionStatus.success:
        return 'Success';
      case ExecutionStatus.partial:
        return 'Partial';
      case ExecutionStatus.failed:
        return 'Failed';
    }
  }

  String toJson() => name;

  static ExecutionStatus fromJson(String json) =>
      ExecutionStatus.values.firstWhere((e) => e.name == json);
}
