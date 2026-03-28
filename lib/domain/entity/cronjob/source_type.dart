enum SourceType {
  promptLibrary,
  website,
}

extension SourceTypeExtension on SourceType {
  String get displayName {
    switch (this) {
      case SourceType.promptLibrary:
        return 'Prompt Library';
      case SourceType.website:
        return 'Website Source';
    }
  }

  String toJson() => name;

  static SourceType fromJson(String json) =>
      SourceType.values.firstWhere((e) => e.name == json);
}
