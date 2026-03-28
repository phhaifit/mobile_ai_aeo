enum PublishingDestination {
  website,
  facebook,
  linkedin,
  wikipedia,
}

extension PublishingDestinationExtension on PublishingDestination {
  String get displayName {
    switch (this) {
      case PublishingDestination.website:
        return 'Website/Blog';
      case PublishingDestination.facebook:
        return 'Facebook';
      case PublishingDestination.linkedin:
        return 'LinkedIn';
      case PublishingDestination.wikipedia:
        return 'Wikipedia';
    }
  }

  String toJson() => name;

  static PublishingDestination fromJson(String json) =>
      PublishingDestination.values.firstWhere((e) => e.name == json);
}
