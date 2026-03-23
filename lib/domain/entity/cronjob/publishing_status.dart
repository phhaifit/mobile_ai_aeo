enum PublishingStatus {
  success,
  partial,
  failed,
}

extension PublishingStatusExtension on PublishingStatus {
  String get displayName {
    switch (this) {
      case PublishingStatus.success:
        return 'Success';
      case PublishingStatus.partial:
        return 'Partial';
      case PublishingStatus.failed:
        return 'Failed';
    }
  }

  String toJson() => name;

  static PublishingStatus fromJson(String json) =>
      PublishingStatus.values.firstWhere((e) => e.name == json);
}
